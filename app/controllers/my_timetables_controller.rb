class MyTimetablesController < ApplicationController
  include HeaderBackPath
  before_action :authenticate_user!, except: :show
  before_action :set_festival!, except: :index
  before_action :set_selected_day!, except: :index
  before_action :load_timetable_data, only: [ :edit, :show ]
  before_action :group_performances_by_stage, only: [ :edit, :show ]
  before_action :build_timeline_view_context, only: [ :edit, :show ]
  before_action :set_header_back_path, only: [ :index, :edit ]
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
    @conflicts = MyTimetables::ConflictDetector.call(@performances)

    @selected_performance_ids = @performances.map(&:id)
  end

  private

  def set_festival!
    slug = params[:festival_id] || params[:id]
    @festival = Festival.find_by_slug!(slug)
  end

  def set_selected_day!
    @festival_days = @festival.timetable_days
    @selected_day = @festival.select_day(params[:date], days: @festival_days)
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

  def load_timetable_data
    @stages = @festival.stages.order(:sort_order, :id)
    @performances =
      @festival
        .stage_performances_on(@selected_day)
        .scheduled
        .includes(:stage, :artist)
  end

  def group_performances_by_stage
    @performances_by_stage = @performances.group_by(&:stage)
  end

  def build_timeline_view_context
    view_context = Timetables::ViewContextBuilder.build(
      festival: @festival,
      selected_day: @selected_day
    )

    @timezone = view_context.timezone
    @timeline_start = view_context.timeline_start
    @timeline_end   = view_context.timeline_end
    @time_markers   = view_context.time_markers
    @timeline_layout = view_context.timeline_layout
  end

  def default_back_path
    # edit のときだけマイタイムテーブルへ戻す
    return nil unless action_name == "edit"

    options = {}
    options[:date] = @selected_day.date.to_s if @selected_day&.date
    options[:user_id] = current_user&.uuid if user_signed_in?
    festival_my_timetable_path(@festival, options)
  end
end
