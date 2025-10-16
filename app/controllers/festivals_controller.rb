class FestivalsController < ApplicationController
  def show
    @festival = Festival.find(params[:id])
  end

  def index
    @status = params[:status]
    @status = "upcoming" unless %w[upcoming past].include?(@status)
    @status_labels = { "upcoming" => "開催前", "past" => "開催済み" }

    @pagy, @festivals = pagy(filtered_festivals, items: 20, params: { status: @status })
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
