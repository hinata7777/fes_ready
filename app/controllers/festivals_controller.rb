class FestivalsController < ApplicationController
  before_action :set_festival, only: :show

  def index
    @artist = nil
    @status = Festival.normalized_status(params[:status])
    @status_labels = Festival.status_labels

    base   = Festival.for_status(@status)
    @q     = base.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, items: 20, params: pagy_params)
  end

  def show
  end

  private

  def set_festival
    relation = Festival.includes(:festival_days, :stages)
    @festival = Festival.find_by_slug!(params[:id], scope: relation)
  end
end
