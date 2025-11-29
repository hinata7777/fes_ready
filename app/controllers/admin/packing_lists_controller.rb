class Admin::PackingListsController < Admin::BaseController
  helper PackingListsHelper

  before_action :set_packing_list, only: [ :edit, :update, :destroy ]
  before_action :set_available_items, only: [ :new, :create, :edit, :update ]

  def index
    @pagy, @packing_lists = pagy(PackingList.templates.includes(:packing_list_items).order(:title), limit: 20)
  end

  def new
    @packing_list = PackingList.new(template: true)
    prepare_form_data
  end

  def create
    @packing_list = PackingList.new(packing_list_params.merge(template: true, user: nil))
    if @packing_list.save
      redirect_to admin_packing_lists_path, notice: "テンプレート持ち物リストを作成しました"
    else
      prepare_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    prepare_form_data
  end

  def update
    if @packing_list.update(packing_list_params.merge(template: true, user: nil))
      redirect_to admin_packing_lists_path, notice: "テンプレート持ち物リストを更新しました"
    else
      prepare_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @packing_list.destroy!
    redirect_to admin_packing_lists_path, notice: "テンプレート持ち物リストを削除しました"
  end

  private

  def set_packing_list
    @packing_list = PackingList.templates.find(params[:id])
  end

  def set_available_items
    @available_items = Item.templates.order(:name)
  end

  def prepare_form_data
    @sorted_items = @packing_list.packing_list_items.includes(:item).sort_by { |pli| [ pli.position || 0, pli.id || 0 ] }
    @next_position_value = (@sorted_items.map { |pli| pli.position || 0 }.max || -1) + 1
  end

  def packing_list_params
    raw = params.require(:packing_list)

    safe = raw.permit(:title).to_h
    safe[:packing_list_items_attributes] = sanitize_packing_list_items(raw[:packing_list_items_attributes])
    safe
  end

  # 動的キー付きのネストを手動でサニタイズ
  def sanitize_packing_list_items(raw_items)
    return [] if raw_items.blank?

    raw_items.to_unsafe_h.map do |_, attrs|
      attrs = attrs.to_unsafe_h if attrs.respond_to?(:to_unsafe_h)
      next unless attrs.is_a?(Hash)

      attrs.slice("id", "item_id", "note", "position", "_destroy")
    end.compact
  end
end
