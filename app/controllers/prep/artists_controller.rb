module Prep
  class ArtistsController < ApplicationController
    include HeaderBackPath
    before_action :set_artist, only: :show

    def index
      artists_scope = Artist.published.order(:name)
      @q     = artists_scope.ransack(params[:q])
      result = @q.result(distinct: true)

      @pagy, @artists = pagy(result, params: request.query_parameters)
    end

    def show
      setlists_scope = Setlist
                         .joins(stage_performance: :festival_day)
                         .where(stage_performance: { artist_id: @artist.id })

      ranking = Prep::SongRankingBuilder.build(artist: @artist, setlist_scope: setlists_scope)
      @setlists_count = ranking.setlists_count
      @ranking_entries = ranking.entries
      @pagy, @setlists = pagy(
        setlists_scope
          .includes(stage_performance: { festival_day: :festival })
          .order("festival_days.date DESC"),
        limit: 5
      )
      @setlists_displayed_count = @pagy.to

      set_header_back_path

      respond_to do |format|
        format.html
        format.turbo_stream
      end
    end

    private

    def set_artist
      @artist = Artist.find_published!(params[:id])
    end

    def resolved_back_path(token)
      # "artist" トークンは対象アーティスト詳細へ戻す
      return artist_path(@artist) if token == "artist" && @artist
      nil
    end
  end
end
