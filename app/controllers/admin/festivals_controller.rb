class Admin::FestivalsController < Admin::BaseController
  before_action :set_festival, only: %i[show edit update destroy setup apply]

  def index
    @pagy, @festivals = pagy(
      Festival.includes(:festival_days, :stages).order(start_date: :desc),
      items: 10
    )
  end

  def show; end

  def new
    @festival = Festival.new(timezone: 'Asia/Tokyo')
  end

  def create
    @festival = Festival.new(festival_params_basic)
    if @festival.save
      redirect_to setup_admin_festival_path(@festival), notice: "フェスを作成しました。日程・ステージを設定してください。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @festival.update(festival_params_basic)
      redirect_to admin_festival_path(@festival), notice: "更新しました。"
    else
      render :edit, status: :unprocessable_entity
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

  def apply
    if @festival.update(festival_params_nested)
      redirect_to admin_festival_path(@festival), notice: "日程・ステージを更新しました。"
    else
      render :setup, status: :unprocessable_entity
    end
  end

  private
  
  def set_festival
    @festival = Festival.find(params[:id])
  end

  # 1ページ目（基本情報のみ）
  def festival_params_basic
    params.require(:festival).permit(
      :name, :slug, :venue_name, :city, :prefecture, 
      :start_date, :end_date, :timezone, 
      :official_url
    )
  end

  # setupページ（ネスト＋必要なら基本も一緒に）
  def festival_params_nested
    params.require(:festival).permit(
      :name, :venue_name, :city, :prefecture, :timezone, :start_date, :end_date, :official_url, 
      festival_days_attributes: [:id, :date, :doors_at, :start_at, :end_at, :note, :_destroy],
      stages_attributes:        [:id, :name, :sort_order, :environment, :note, :color_key, :_destroy]
    )
  end
end