class MyTimetablesController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_festival!, except: :index
  before_action :set_selected_day!, except: :index
  before_action :prepare_timetable_context!, only: [ :build, :show ]
  before_action :set_timetable_owner!, only: :show

  def index
    @festival_days =
      FestivalDay
        .joins(:festival, stage_performances: :user_timetable_entries)
        .where(user_timetable_entries: { user_id: current_user.id })
        .includes(:festival)
        .distinct
        .order("festivals.start_date ASC", "festival_days.date ASC")

    @festival_day_groups = @festival_days.group_by(&:festival)
  end

  def build
    @picked_ids = current_user
                    .user_timetable_entries
                    .joins(:stage_performance)
                    .where(stage_performances: { festival_day_id: @selected_day.id })
                    .pluck(:stage_performance_id)
  end

  def create
    ids = Array(params[:stage_performance_ids]).map!(&:to_i)

    allowed_ids = StagePerformance.where(festival_day_id: @selected_day.id).pluck(:id)
    ids &= allowed_ids

    ActiveRecord::Base.transaction do
      current_user.user_timetable_entries
                  .joins(:stage_performance)
                  .where(stage_performances: { festival_day_id: @selected_day.id })
                  .delete_all

      ids.uniq.each do |sp_id|
        current_user.user_timetable_entries.create!(stage_performance_id: sp_id)
      end
    end

    redirect_to my_timetable_festival_path(@festival, date: @selected_day.date.to_s, user_id: current_user.id),
                notice: "マイタイムテーブルを保存しました。"
  end

  def destroy
    current_user
      .user_timetable_entries
      .joins(:stage_performance)
      .where(stage_performances: { festival_day_id: @selected_day.id })
      .delete_all

    redirect_to my_timetables_path, notice: "マイタイムテーブルを削除しました。"
  end

  def show
    @performances = @timetable_owner
                      .my_stage_performances
                      .includes(:artist, :stage, :festival_day)
                      .where(stage_performances: { festival_day_id: @selected_day.id })
                      .order(:starts_at, :ends_at, :id)
    @conflicts = detect_conflicts(@performances)

    @selected_performance_ids = @performances.map(&:id)
  end

  private

  def set_festival!
    slug = params[:festival_id] || params[:id]
    @festival = Festival.find_by!(slug: slug)
  end

  def set_selected_day!
    @festival_days = @festival.timetable_days
    raise ActiveRecord::RecordNotFound if @festival_days.blank?

    @selected_day =
      if params[:date].present?
        @festival.festival_days.find_by!(date: Date.parse(params[:date]))
      else
        @festival_days.first
      end
  end

  def detect_conflicts(list)
    conflicts = Set.new
    last_end = nil
    last_id  = nil
    list.each do |sp|
      if last_end && sp.starts_at && sp.ends_at && sp.starts_at < last_end
        conflicts << last_id
        conflicts << sp.id
      end
      last_end = sp.ends_at || last_end
      last_id  = sp.id
    end
    conflicts
  end

  def set_timetable_owner!
    @timetable_owner =
      if params[:user_id].present?
        User.find(params[:user_id])
      elsif user_signed_in?
        current_user
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def prepare_timetable_context!
    @timezone = ActiveSupport::TimeZone[@festival.timezone] || Time.zone
    @stages   = @festival.stages.order(:sort_order, :id)

    @performances =
      @festival
        .stage_performances_for(@selected_day)
        .scheduled
        .includes(:stage, :artist)

    @performances_by_stage =
      @performances
        .reject { |performance| performance.stage_id.blank? }
        .group_by(&:stage_id)

    @performances_without_stage =
      @performances
        .select { |performance| performance.stage_id.blank? }

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
end
