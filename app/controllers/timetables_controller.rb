class TimetablesController < ApplicationController
  include HeaderBackPath
  before_action :set_festival, only: :show
  before_action :ensure_timetable_published!, only: :show
  before_action :set_header_back_path, only: :show

  def index
    @status = Festivals::ListQuery.normalized_status(params[:status])
    @festival_tags = FestivalTag.order(:name)
    @filter_params = Festivals::FilterQuery.permitted_params(params)
    @selected_tag_ids = Array(@filter_params[:tag_ids]).reject(&:blank?).map(&:to_i)

    published_festivals = Festival.with_published_timetable
    scoped = Festivals::ListQuery.call(status: @status, scope: published_festivals)

    filtered_scope = Festivals::FilterQuery.call(scope: scoped, filters: @filter_params)

    @q = filtered_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, limit: 20, params: pagy_params)
    @back_to = request.fullpath
  end

  def show
    # URLパラメータを整理し、表示対象の日程を確定する
    @timetable_query_params = timetable_query_params
    load_selected_day

    # タイムラインの表示情報をまとめて生成する
    view_context = Timetables::ViewContextBuilder.build(
      festival: @festival,
      selected_day: @selected_day
    )

    # ステージ列の並びと、列ごとの出演枠を用意する
    @stages = @festival.stages.sort_by { |stage| [ stage.sort_order || 0, stage.id ] }
    @performances_by_stage = performances_by_stage

    # view_context からタイムライン表示に必要な値を展開する
    @timezone = view_context.timezone
    @timeline_start = view_context.timeline_start
    @timeline_end   = view_context.timeline_end
    @time_markers   = view_context.time_markers
    @timeline_layout = view_context.timeline_layout
  end

  private

  def set_festival
    @festival = Festival.includes(:festival_days, :stages).find_by_slug!(params[:id])
  end

  def ensure_timetable_published!
    raise ActiveRecord::RecordNotFound unless @festival.timetable_published?
  end

  def load_selected_day
    # 選択可能な開催日（タブ）を並び替えた一覧として保持
    @festival_days = @festival.timetable_days
    @selected_day = @festival.select_day(params[:date], days: @festival_days)
  end

  def performances_by_stage
    # 指定日の出演枠をステージ単位にまとめ、タイムテーブルの列へ渡す
    @performances_by_stage ||=
      @festival
        .stage_performances_on(@selected_day)
        .scheduled
        .where.not(stage_id: nil)
        .includes(:stage, :artist)
        .group_by(&:stage)
  end

  def timetable_query_params
    params.permit(:from, :artist_id, :festival_id, :user_id, :back_to).to_h
  end

  def resolved_back_path(token)
    # "festival" トークンは対象フェスの詳細へ戻す
    return festival_path(@festival) if token == "festival" && @festival
    nil
  end
end
