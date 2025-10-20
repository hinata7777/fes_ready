class FestivalsController < ApplicationController
  def index
    @artist = Artist.find(params[:artist_id]) if params[:artist_id].present?

    @status = params[:status]
    @status = "upcoming" unless %w[upcoming past].include?(@status)
    @status_labels = { "upcoming" => "開催前", "past" => "開催済み" }

    base   = filtered_festivals
    @q     = base.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, items: 20, params: pagy_params)
  end

  def show
    @festival = Festival.find(params[:id])
  end

  private

  def filtered_festivals
    relation =
      if @artist
        @artist.festivals.merge(Festival.ordered)
      else
        Festival.ordered
      end

    today = Date.current
    scoped =
      case @status
      when "past" then relation.merge(Festival.past(today))
      else           relation.merge(Festival.upcoming(today))
      end

    scoped.distinct
  end
end
