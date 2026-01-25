class PackingListsController < ApplicationController
  include HeaderBackPath
  before_action :authenticate_user!, except: :index
  before_action :set_packing_list, only: :show
  before_action :set_owned_packing_list, only: [ :edit, :update, :destroy ]
  before_action :set_available_items, only: [ :new, :create, :edit, :update ]
  before_action :set_header_back_path, only: [ :edit, :update ]

  def index
    @template_lists = PackingList.templates.order(:title)
    @packing_lists = current_user ? current_user.packing_lists.order(created_at: :desc) : []
  end

  def show
    @packing_list_items = @packing_list.packing_list_items.includes(:item).order(:position, :id)
    # 天気は「日程あり + フェスに緯度経度あり」のときだけ表示する想定。
    # 取得失敗などのケースでは service が nil を返すため、画面は落ちずに天気だけ非表示になる。
    @festival_weather_forecast = Weather::FestivalDayForecast.new(festival_day: @packing_list.festival_day).call
  end

  def new
    @packing_list = PackingListForm.new(user: current_user, template_id: params[:template_id]).packing_list
    prepare_form_data
  end

  def create
    form = PackingListForm.new(user: current_user, params: params)
    @packing_list = form.packing_list
    if form.save
      redirect_to @packing_list, notice: "持ち物リストを作成しました"
    else
      flash.now[:alert] = title_error_message if @packing_list.errors[:title].present?
      prepare_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    prepare_form_data
  end

  def update
    form = PackingListForm.new(user: current_user, packing_list: @packing_list, params: params)
    if form.save
      redirect_to @packing_list, notice: "持ち物リストを更新しました"
    else
      flash.now[:alert] = title_error_message if @packing_list.errors[:title].present?
      prepare_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @packing_list.destroy!
    redirect_to packing_lists_path, notice: "持ち物リストを削除しました"
  end

  private

  def set_packing_list
    @packing_list = PackingList
      .includes(festival_day: :festival)
      .templates
      .or(PackingList.owned_by(current_user))
      .find_by!(uuid: params[:id])
  end

  def set_owned_packing_list
    @packing_list = current_user.packing_lists.includes(festival_day: :festival).find_by!(uuid: params[:id])
  end

  def set_available_items
    @available_items = Item.templates.order(:name)
  end

  def title_error_message
    "既に登録されているリスト名です"
  end

  def prepare_form_data
    @sorted_items = @packing_list.packing_list_items.sort_by { |pli| [ pli.position || 0, pli.id || 0 ] }
    @next_position_value = (@sorted_items.map { |pli| pli.position || 0 }.max || -1) + 1
    upcoming_days = FestivalDay.for_packing_list_select.to_a
    @festival_days = upcoming_days

    past_selected_day = @packing_list&.past_selected_festival_day

    @festival_days |= [ past_selected_day ].compact
  end

  def default_back_path
    # 編集/更新時は編集中のリストへ戻す
    packing_list_path(@packing_list) if @packing_list&.persisted?
  end
end
