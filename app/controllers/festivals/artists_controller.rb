class Festivals::ArtistsController < ApplicationController
  before_action :set_festival
  before_action :set_festival_days

  def index
    artists_scope = @festival.artists_for_day(@selected_festival_day)

    @q     = artists_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    @pagy, @artists = pagy(result, params: request.query_parameters)

    render "artists/index"
  end

  private

  def set_festival
    @festival = Festival.find_by_slug!(params[:festival_id])
  end

  def set_festival_days
    @festival_days = @festival.festival_days.order(:date)
    @selected_festival_day = @festival_days.find_by(id: params[:festival_day_id]) || @festival_days.first
  end
end
