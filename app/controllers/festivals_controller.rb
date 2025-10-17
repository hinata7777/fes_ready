class FestivalsController < ApplicationController
  def show
    @festival = Festival.find(params[:id])
  end

  def index
    @status = params[:status]
    @status = "upcoming" unless %w[upcoming past].include?(@status)
    @status_labels = { "upcoming" => "開催前", "past" => "開催済み" }

    base   = filtered_festivals
    @q     = base.ransack(params[:q])
    result = @q.result(distinct: true)

    @pagy, @festivals = pagy(result, items: 20, params: { status: @status, q: params[:q] })
  end

  private

  def filtered_festivals
    today = Date.current
    case @status
    when "past"     then Festival.ordered.past(today)
    else                 Festival.ordered.upcoming(today)
    end
  end
end