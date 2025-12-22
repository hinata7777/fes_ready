class SetlistsController < ApplicationController
  before_action :set_header_back_path, only: :show

  def show
    @setlist = Setlist
                .includes(stage_performance: [ :artist, :stage, { festival_day: :festival } ],
                          setlist_songs: :song)
                .find_by!(uuid: params[:id])

    @stage_performance = @setlist.stage_performance
    @festival_day      = @stage_performance.festival_day
    @setlist_songs     = @setlist.setlist_songs.includes(:song).order(:position)
  end

  private

  def set_header_back_path
    back = params[:back_to].to_s
    return if back.blank?
    return unless back.start_with?("/")

    @header_back_path = back
  end
end
