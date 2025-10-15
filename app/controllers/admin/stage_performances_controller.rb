class Admin::StagePerformancesController < Admin::BaseController
  before_action :set_sp, only: %i[show edit update destroy]

  def index
    @pagy, @stage_performances =
      pagy(StagePerformance
        .includes(:festival_day, :stage, :artist)
        .order(:starts_at))
  end

  def show; end

  def new
    @stage_performance = StagePerformance.new(status: :draft)
    @stage_performance.festival_day_id = params[:festival_day_id] if params[:festival_day_id].present?
  end

  def create
    @stage_performance = StagePerformance.new(sp_params)
    if @stage_performance.save
      redirect_to admin_stage_performance_path(@stage_performance), notice: "出演枠を作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::StatementInvalid => e
    flash.now[:alert] = friendly_pg_error(e)
    render :new, status: :unprocessable_entity
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

  def set_sp
    @stage_performance = StagePerformance.includes(:artist, :stage, festival_day: :festival).find(params[:id])
  end

  def sp_params
    params.require(:stage_performance).permit(
      :festival_day_id, :stage_id, :artist_id,
      :starts_at, :ends_at, :status
    )
  end

  def friendly_pg_error(err)
    msg = err.message
    return "同一ステージで時間帯が重複しています（確定枠）。時間を見直してください。" if msg.include?("no_overlap_on_same_stage_when_scheduled")
    return "同一スロットの二重登録です（確定枠）。開始時刻・ステージ・アーティストの組み合わせを見直してください。" if msg.include?("uniq_sp_slot_when_scheduled")
    "保存に失敗しました（DB制約）。入力内容を確認してください。"
  end
end
