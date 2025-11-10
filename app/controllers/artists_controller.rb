class ArtistsController < ApplicationController
  def index
    @festival = Festival.find_by(slug: params[:festival_id])

    base =
    if @festival
      @festival_days = @festival.festival_days.order(:date)
      @selected_festival_day = if params[:festival_day_id].present?
        @festival_days.find_by(id: params[:festival_day_id])
      end
      @selected_festival_day ||= @festival_days.first

      if @selected_festival_day
        Artist
          .joins(stage_performances: :festival_day)
          .where(stage_performances: { festival_day_id: @selected_festival_day.id })
          .distinct
          .includes(stage_performances: :festival_day)
      else
        Artist.none
      end
    else
      @festival_days = []
      @selected_festival_day = nil
      Artist.all
    end

    base = base.order(:name)

    @q     = base.ransack(params[:q])
    result = @q.result(distinct: true)

    @pagy, @artists = pagy(result, params: request.query_parameters)
  end

  def show
    @artist = find_artist_by_identifier!(params[:id])
  end

  private

  def find_artist_by_identifier!(identifier)
    Artist.find_by(uuid: identifier) || Artist.find(identifier)
  end
end
