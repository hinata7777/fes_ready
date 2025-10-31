class FestivalsController < ApplicationController
  before_action :set_festival, only: [ :show, :timetable ]
  before_action :ensure_timetable_published!, only: :timetable

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
  end

  def timetable
    @festival_days = @festival.timetable_days
    raise ActiveRecord::RecordNotFound if @festival_days.blank?

    @timetable_query_params =
      params.permit(:from, :artist_id, :festival_id, :user_id).to_h

    @selected_day =
      if params[:date].present?
        begin
          date = Date.parse(params[:date])
        rescue ArgumentError
          raise ActiveRecord::RecordNotFound
        end
        @festival.festival_days.find_by!(date: date)
      else
        @festival_days.first
      end

    @timezone = ActiveSupport::TimeZone[@festival.timezone] || Time.zone

    @stages = @festival.stages.order(:sort_order, :id)

    @performances =
      @festival
        .stage_performances_for(@selected_day)
        .scheduled
        .includes(:stage, :artist)

    @performances_by_stage =
      @performances
        .reject { |performance| performance.stage_id.blank? }
        .group_by(&:stage_id)

    day_date  = @selected_day.date
    day_start = @timezone.local(day_date.year, day_date.month, day_date.day).beginning_of_day
    day_end   = day_start.end_of_day

    compose_time = lambda do |time|
      next nil unless time
      local = time.in_time_zone(@timezone)
      @timezone.local(day_date.year, day_date.month, day_date.day, local.hour, local.min, local.sec)
    rescue
      nil
    end

    doors_at = compose_time.call(@selected_day.doors_at)
    start_at = compose_time.call(@selected_day.start_at)
    end_at   = compose_time.call(@selected_day.end_at)

    default_start = doors_at || start_at || @timezone.local(day_date.year, day_date.month, day_date.day, 9, 0, 0)
    default_end   = end_at || (start_at || default_start) + 8.hours

    @timeline_start = [ [ default_start, day_start ].max, day_end ].min
    @timeline_end   = [ [ default_end, day_start ].max, day_end ].min

    if @timeline_end <= @timeline_start
      @timeline_end = [ @timeline_start + 1.hour, day_end ].min
    end

    @time_markers = []
    @time_markers << @timeline_start

    marker =
      if @timeline_start.min.zero? && @timeline_start.sec.zero?
        @timeline_start + 1.hour
      else
        (@timeline_start + 1.hour).change(min: 0, sec: 0)
      end

    while marker <= @timeline_end
      @time_markers << marker
      marker += 1.hour
    end

    @time_markers << @timeline_end unless @time_markers.last == @timeline_end
  end

  private

  def set_festival
    @festival = Festival.includes(:festival_days, :stages).find_by!(slug: params[:id])
  end

  def ensure_timetable_published!
    raise ActiveRecord::RecordNotFound unless @festival.timetable_published?
  end

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
