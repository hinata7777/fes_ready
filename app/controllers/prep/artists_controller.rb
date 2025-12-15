module Prep
  class ArtistsController < ApplicationController
    before_action :set_artist, only: :show

    def index
      artists_scope = Artist.published.order(:name)
      @q     = artists_scope.ransack(params[:q])
      result = @q.result(distinct: true)

      @pagy, @artists = pagy(result, params: request.query_parameters)
    end

    def show
      @setlist_scope = Setlist
                        .joins(stage_performance: :festival_day)
                        .includes(stage_performance: [ :artist, :stage, { festival_day: :festival } ])
                        .where(stage_performances: { artist_id: @artist.id })
                        .order("festival_days.date DESC")

      @setlists_count = @setlist_scope.count
      @setlists = @setlist_scope

      @ranking_entries =
        if @setlists_count >= 3
          ranked_songs = Song
                         .joins(setlist_songs: :setlist)
                         .where(artist_id: @artist.id, setlists: { id: @setlist_scope.select(:id) })
                         .select("songs.*", "COUNT(DISTINCT setlist_songs.setlist_id) AS appearances_count")
                         .group("songs.id")
                         .order("appearances_count DESC", "songs.name ASC")
                         .limit(5)

          ranked_songs.map do |song|
            count = song.read_attribute(:appearances_count).to_i
            rate  = ((count.to_f / @setlists_count) * 100).round(1)
            { song: song, count: count, rate: rate }
          end
        else
          []
        end
    end

    private

    def set_artist
      @artist = Artist.find_published!(params[:id])
    end
  end
end
