class Admin::StagePerformancesController < Admin::BaseController
  before_action :set_stage_performance, only: %i[show edit update destroy]
  before_action :prepare_form_options, only: %i[new create edit update]

  def index
    @festival_days = FestivalDay.includes(:festival).order(:date)
    @artists = Artist.order(:name)

    scope = StagePerformance.includes(:festival_day, :stage, :artist)
                            .order(:starts_at)
                            .for_day(params[:festival_day_id])
                            .for_artist(params[:artist_id])
    @pagy, @stage_performances = pagy(scope)
  end

  def show; end

  def new
    @bulk_form = Admin::StagePerformances::BulkForm.new({})
    @bulk_entries = Admin::StagePerformances::BulkForm.empty_entries
  end

  def create
    form = Admin::StagePerformances::BulkForm.new(bulk_params)

    if form.save
      redirect_to admin_stage_performances_path, notice: "#{form.created_count}件の出演枠を追加しました。"
    else
      @bulk_form = form
      @bulk_entries = form.bulk_entries
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @stage_performance.update(sp_params)
      redirect_to admin_stage_performance_path(@stage_performance), notice: "出演枠を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::StatementInvalid => e
    flash.now[:alert] = friendly_pg_error(e)
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @stage_performance.destroy!
    redirect_to admin_stage_performances_path, notice: "削除しました。"
  end

  private

  def set_stage_performance
    @stage_performance = StagePerformance.includes(:artist, :stage, festival_day: :festival).find(params[:id])
  end

  def sp_params
    params.require(:stage_performance).permit(
      :festival_day_id, :stage_id, :artist_id,
      :starts_at, :ends_at, :status, :canceled
    )
  end

  def bulk_params
    params.require(:bulk).permit(
      :festival_day_id,
      :stage_id,
      entries: %i[artist_id starts_at ends_at status canceled]
    )
  end

  def friendly_pg_error(err)
    msg = err.message
    return "同一ステージで時間帯が重複しています（確定枠）。時間を見直してください。" if msg.include?("no_overlap_on_same_stage_when_scheduled")
    return "同一スロットの二重登録です（確定枠）。開始時刻・ステージ・アーティストの組み合わせを見直してください。" if msg.include?("uniq_sp_slot_when_scheduled")
    "保存に失敗しました（DB制約）。入力内容を確認してください。"
  end

  def prepare_form_options
    @festival_days = FestivalDay.includes(:festival).order(:date)
    @artists = Artist.order(:name)
    @stages_by_festival = Stage.order(:sort_order, :id).group_by(&:festival_id)
    @festival_day_festival_map = @festival_days.map { |day| [ day.id, day.festival_id ] }.to_h
    @festival_day_date_map = @festival_days.map { |day| [ day.id, day.date.iso8601 ] }.to_h
    @stage_options = @stages_by_festival.transform_values { |stages| stages.map { |stage| { id: stage.id, name: stage.name } } }
    @stage_collection = @stages_by_festival.values.flatten
  end
end
