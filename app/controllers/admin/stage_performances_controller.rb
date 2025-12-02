class Admin::StagePerformancesController < Admin::BaseController
  before_action :set_stage_performance, only: %i[show edit update destroy]
  before_action :prepare_form_options, only: %i[new create edit update bulk_new bulk_create]

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

  def bulk_new
    @bulk_entries = Array.new(10) { StagePerformance.new(status: :draft) }
  end

  def bulk_create
    permitted = bulk_params
    entry_attrs = normalize_bulk_entries(permitted[:entries])
    # アーティスト未選択の行は無視し、有効な行だけをまとめて保存する
    usable_entries = entry_attrs.select { |attrs| attrs[:artist_id].present? }

    if usable_entries.empty?
      flash.now[:alert] = "1行以上入力してください。"
      @bulk_entries = build_bulk_entries(entry_attrs)
      render :bulk_new, status: :unprocessable_entity and return
    end

    StagePerformance.transaction do
      usable_entries.each do |attrs|
        canceled_value = ActiveModel::Type::Boolean.new.cast(attrs[:canceled])
        canceled_value = false if canceled_value.nil?

        StagePerformance.create!(
          festival_day_id: permitted[:festival_day_id],
          stage_id: permitted[:stage_id],
          artist_id: attrs[:artist_id],
          starts_at: attrs[:starts_at],
          ends_at: attrs[:ends_at],
          status: attrs[:status].presence || :draft,
          canceled: canceled_value
        )
      end
    end

    redirect_to admin_stage_performances_path, notice: "#{usable_entries.size}件の出演枠を追加しました。"
  rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
    flash.now[:alert] =
      if e.is_a?(ActiveRecord::StatementInvalid)
        friendly_pg_error(e)
      else
        e.record.errors.full_messages.first || "保存に失敗しました。"
      end
    @bulk_entries = build_bulk_entries(entry_attrs)
    render :bulk_new, status: :unprocessable_entity
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

  def build_bulk_entries(entries)
    filled = entries.presence || []
    entries_as_models = filled.map { |attrs| StagePerformance.new(attrs) }
    padding = [ 10 - entries_as_models.size, 0 ].max
    entries_as_models + Array.new(padding) { StagePerformance.new(status: :draft) }
  end

  # params[:entries] が Array/ActionController::Parameters どちらでもシンボルキーの配列に揃える
  def normalize_bulk_entries(entries_param)
    return [] if entries_param.blank?

    raw_entries = case entries_param
    when Array
                    entries_param
    when ActionController::Parameters
                    entries_param.to_h.values
    else
                    []
    end

    raw_entries.map { |attrs| attrs.to_h.symbolize_keys }
  end
end
