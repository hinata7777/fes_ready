module Prep
  class FestivalsController < ApplicationController
    include HeaderBackPath
    def index
      @status = Festivals::ListQuery.normalized_status(params[:status])
      @festival_tags = FestivalTag.order(:name)
      @filter_params = Festivals::FilterQuery.permitted_params(params)
      @selected_tag_ids = Array(@filter_params[:tag_ids]).reject(&:blank?).map(&:to_i)

      scoped = Festivals::ListQuery.call(status: @status)
      filtered_scope = Festivals::FilterQuery.call(scope: scoped, filters: @filter_params)

      @q = filtered_scope.ransack(params[:q])
      result = @q.result(distinct: true)

      pagy_params = request.query_parameters.merge(status: @status)
      @pagy, @festivals = pagy(result, limit: 20, params: pagy_params)
    end

    def show
      @festival = find_festival
      @festival_days = @festival.timetable_days
      raise ActiveRecord::RecordNotFound if @festival_days.blank?

      resolve_selected_day
      build_song_entries
      set_header_back_path
    end

    private

    def find_festival
      festival_relation = Festival.includes(:festival_days)
      Festival.find_by_slug!(params[:id], scope: festival_relation)
    end

    def resolve_selected_day
      @selected_day =
        if params[:date].present?
          parsed = Date.parse(params[:date]) rescue nil
          raise ActiveRecord::RecordNotFound unless parsed
          @festival.festival_days.find_by!(date: parsed)
        else
          @festival_days.first
        end
    end

    def build_song_entries
      performing_artists = Artist
                             .joins(stage_performances: :festival_day)
                             .where(stage_performances: { status: StagePerformance.statuses[:scheduled] },
                                    festival_days: { id: @selected_day.id, festival_id: @festival.id })
                             .merge(Artist.published)
                             .distinct
                             .order(:name)

      entries = performing_artists.flat_map do |artist|
        setlist_scope = Setlist
                         .joins(:stage_performance)
                         .where(stage_performances: { artist_id: artist.id })

        setlists_count = setlist_scope.count
        next if setlists_count < 3

        ranked_songs = Song
                        .joins(setlist_songs: :setlist)
                        .where(artist_id: artist.id, setlists: { id: setlist_scope.select(:id) })
                        .select("songs.*", "COUNT(DISTINCT setlist_songs.setlist_id) AS appearances_count")
                        .group("songs.id")
                        .order("appearances_count DESC", "songs.name ASC")
                        .limit(5)

        spotify_pick = ranked_songs
                        .select { |song| song.spotify_id.present? }
                        .first(2)

        next if spotify_pick.empty?

        spotify_pick.map do |song|
          count = song.read_attribute(:appearances_count).to_i
          rate  = ((count.to_f / setlists_count) * 100).round(1)
          { artist: artist, song: song, count: count, rate: rate }
        end
      end.compact

      @pagy, @song_entries = pagy_array(entries, limit: 10, page: params[:page])
    end

    def resolved_back_path(token)
      # "festival" トークンは対象フェスの詳細へ戻す
      return festival_path(@festival) if token == "festival" && @festival
      nil
    end
  end
end
