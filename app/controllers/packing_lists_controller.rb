class PackingListsController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_packing_list, only: [ :show, :edit, :update, :destroy, :duplicate_from_template ]
  before_action :set_owned_packing_list, only: [ :edit, :update, :destroy ]
  before_action :set_available_items, only: [ :new, :create, :edit, :update ]

  def index
    @template_lists = PackingList.templates.order(:title)
    @packing_lists = current_user ? current_user.packing_lists.order(created_at: :desc) : []
  end

  def show
    @packing_list_items = @packing_list.packing_list_items.includes(:item).order(:position, :id)
  end

  def new
    @packing_list = current_user.packing_lists.build
    apply_template_if_present
    prepare_form_data
  end

  def create
    @packing_list = current_user.packing_lists.build(packing_list_params)
    assign_owner_to_new_items(@packing_list)
    if @packing_list.save
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
    @packing_list.assign_attributes(packing_list_params)
    assign_owner_to_new_items(@packing_list)
    if @packing_list.save
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

  def duplicate_from_template
    unless @packing_list.template?
      redirect_to packing_lists_path, alert: "テンプレートのみ複製できます" and return
    end

    new_list = current_user.packing_lists.build(title: @packing_list.title)
    ActiveRecord::Base.transaction do
      new_list.save!
      @packing_list.packing_list_items.find_each do |pli|
        new_list.packing_list_items.create!(
          item_id: pli.item_id,
          position: pli.position,
          note: pli.note
        )
      end
    end

    redirect_to new_list, notice: "テンプレートからリストを作成しました"
  rescue ActiveRecord::RecordInvalid
    redirect_to packing_lists_path, alert: "複製に失敗しました"
  end

  private

  def set_packing_list
    @packing_list = PackingList.templates.or(PackingList.owned_by(current_user)).find(params[:id])
  end

  def set_owned_packing_list
    @packing_list = current_user.packing_lists.find(params[:id])
  end

  def set_available_items
    @available_items = Item.templates.order(:name)
  end

  def assign_owner_to_new_items(packing_list)
    packing_list.packing_list_items.each do |pli|
      pli.packing_list ||= packing_list
      next unless pli.item&.new_record?

      item_name = pli.item.name.to_s.strip
      if item_name.present?
        existing_item = current_user.items.find_by(name: item_name) || Item.templates.find_by(name: item_name)
        if existing_item
          pli.item = existing_item
          next
        end
      end

      pli.item.user = current_user
      pli.item.template = false
    end
  end

  def title_error_message
    "既に登録されているリスト名です"
  end

  def prepare_form_data
    @sorted_items = @packing_list.packing_list_items.sort_by { |pli| [ pli.position || 0, pli.id || 0 ] }
    @next_position_value = (@sorted_items.map { |pli| pli.position || 0 }.max || -1) + 1
  end

  def apply_template_if_present
    template_id = params[:template_id]
    return if template_id.blank?

    template = PackingList.templates.find_by(id: template_id)
    return unless template

    @packing_list.title = template.title
    template.packing_list_items.includes(:item).order(:position, :id).each do |pli|
      @packing_list.packing_list_items.build(
        item_id: pli.item_id,
        position: pli.position,
        note: pli.note
      )
    end
  end

  def packing_list_params
    raw = params.require(:packing_list)

    safe = raw.permit(:title).to_h
    safe[:packing_list_items_attributes] = sanitize_packing_list_items(raw[:packing_list_items_attributes])
    safe
  end

  # 動的キー付きのネストを手動でサニタイズして通す
  def sanitize_packing_list_items(raw_items)
    return [] if raw_items.blank?

    raw_items.to_unsafe_h.map do |_, attrs|
      attrs = attrs.to_unsafe_h if attrs.respond_to?(:to_unsafe_h)
      next unless attrs.is_a?(Hash)

      item_attrs = attrs["item_attributes"] || {}
      sanitized_item = item_attrs.slice("id", "name", "description", "category") if item_attrs.is_a?(Hash)
      base = attrs.slice("id", "item_id", "note", "position", "_destroy")
      sanitized_item.present? ? base.merge("item_attributes" => sanitized_item) : base
    end.compact
  end
end
