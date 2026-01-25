class Admin::FestivalsController < Admin::BaseController
  before_action :set_festival, only: %i[show edit update destroy setup]
  before_action :load_festival_tags, only: %i[new edit setup create update]

  def index
    @pagy, @festivals = pagy(
      Festival.order(start_date: :desc),
      limit: 10
    )
  end

  def show
    @selected_festival_tags = @festival.sorted_tags
  end

  def new
    @festival = Festival.new(timezone: "Asia/Tokyo")
  end

  def create
    @festival = Festival.new(festival_params)
    if @festival.save
      redirect_to setup_admin_festival_path(@festival), notice: "フェスを作成しました。日程・ステージを設定してください。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @festival.update(festival_params)
      notice = nested_update_request? ? "日程・ステージを更新しました。" : "更新しました。"
      redirect_to admin_festival_path(@festival), notice: notice
    else
      render_update_failure
    end
  end

  def destroy
    @festival.destroy!
    redirect_to admin_festivals_path, notice: "削除しました。"
  end

  # —— ネスト編集ステップ ——
  def setup
    @festival.festival_days.build if @festival.festival_days.blank?
    @festival.stages.build        if @festival.stages.blank?
  end

  private

  def set_festival
    @festival = Festival.find_by_slug!(params[:id])
  end

  def load_festival_tags
    @festival_tags = FestivalTag.order(:name)
  end

  # 基本情報＋ネストをまとめて許可する。
  def festival_params
    params.require(:festival).permit(
      :name, :slug, :venue_name, :city, :prefecture,
      :start_date, :end_date, :timezone,
      :official_url, :timetable_published,
      :latitude, :longitude,
      festival_tag_ids: [],
      festival_days_attributes: [ :id, :date, :doors_at, :start_at, :end_at, :note, :_destroy ],
      stages_attributes:        [ :id, :name, :sort_order, :note, :color_key, :_destroy ]
    )
  end

  def nested_update_request?
    # setupフォーム（ネスト更新）か通常編集かを判別する
    attrs = params[:festival] || {}
    attrs.key?(:festival_days_attributes) || attrs.key?(:stages_attributes)
  end

  def render_update_failure
    # setupフォームの場合はsetupに戻す
    if nested_update_request?
      render :setup, status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
