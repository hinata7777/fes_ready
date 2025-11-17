class MyTimetablesController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_festival!, except: :index
  before_action :set_selected_day!, except: :index
  before_action :prepare_timetable_context!, only: [ :edit, :show ]
  before_action :set_timetable_owner!, only: :show

  def index
    festival_days = FestivalDay.for_user(current_user)
    @festival_day_groups = festival_days.group_by(&:festival)
  end

  def edit
    @picked_ids = current_user.stage_performance_ids_for_day(@selected_day)
  end

  def update
    MyTimetables::Updater.call(
      user: current_user,
      festival_day: @selected_day,
      stage_performance_ids: params[:stage_performance_ids]
    )
    redirect_to festival_my_timetable_path(@festival, date: @selected_day.date.to_s, user_id: current_user.uuid),
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
    @festival = Festival.find_by_slug!(slug)
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
        find_user_by_identifier!(params[:user_id])
      elsif user_signed_in?
        current_user
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def find_user_by_identifier!(identifier)
    user = User.find_by(uuid: identifier) || User.find_by(id: identifier)
    user || raise(ActiveRecord::RecordNotFound)
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
        .group_by(&:stage_id)

    timeline_context = TimelineContextBuilder.build(
      festival: @festival,
      selected_day: @selected_day,
      timezone: @timezone
    )

    @timeline_start = timeline_context.timeline_start
    @timeline_end   = timeline_context.timeline_end
    @time_markers   = timeline_context.time_markers
    @timeline_layout = timeline_context.timeline_layout
  end
end
