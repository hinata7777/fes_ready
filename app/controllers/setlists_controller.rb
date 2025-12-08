class SetlistsController < ApplicationController
  def show
    @setlist = Setlist
                .includes(stage_performance: [ :artist, :stage, { festival_day: :festival } ],
                          setlist_songs: :song)
                .find_by!(uuid: params[:id])

    @stage_performance = @setlist.stage_performance
    @festival_day      = @stage_performance.festival_day
    @setlist_songs     = @setlist.setlist_songs.includes(:song).order(:position)
  end
end
