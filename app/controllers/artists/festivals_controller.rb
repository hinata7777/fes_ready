class Artists::FestivalsController < ApplicationController
  before_action :set_artist

  def index
    @status = Festival.normalized_status(params[:status])
    @status_labels = Festival.status_labels

    festival_scope = @artist.festivals.merge(Festival.for_status(@status))
    @q   = festival_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, items: 20, params: pagy_params)

    render "festivals/index"
  end

  private

  def set_artist
    @artist = Artist.find_by_identifier!(params[:artist_id])
  end
end
