class TimetablesController < ApplicationController
  def index
    @status = params[:status]
    @status = "upcoming" unless %w[upcoming past].include?(@status)
    @status_labels = { "upcoming" => "開催前", "past" => "開催済み" }

    today = Date.current
    base  = Festival.with_published_timetable.ordered

    scoped =
      case @status
      when "past" then base.merge(Festival.past(today))
      else             base.merge(Festival.upcoming(today))
      end

    @q = scoped.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, items: 20, params: pagy_params)
  end
end