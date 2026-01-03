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
      @setlists = Setlist
                    .joins(stage_performance: :festival_day)
                    .includes(stage_performance: [ :artist, :stage, { festival_day: :festival } ])
                    .where(stage_performance: { artist_id: @artist.id })
                    .order("festival_days.date DESC")

      ranking = Prep::SongRankingBuilder.build(artist: @artist, setlist_scope: @setlists)
      @setlists_count = ranking.setlists_count
      @ranking_entries = ranking.entries

      set_header_back_path
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
