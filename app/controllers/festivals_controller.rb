class FestivalsController < ApplicationController
  before_action :set_festival, only: :show

  def index
    @artist = nil
    @status = Festival.normalized_status(params[:status])
    @status_labels = Festival.status_labels

    festival_scope = Festival.for_status(@status)
    @q     = festival_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, items: 20, params: pagy_params)
  end

  def show
  end

  private

  def set_festival
    festival_relation = Festival.includes(:festival_days, :stages)
    @festival = Festival.find_by_slug!(params[:id], scope: festival_relation)
  end
end
