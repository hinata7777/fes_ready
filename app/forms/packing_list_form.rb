class PackingListForm
  include ActiveModel::Model

  attr_reader :packing_list

  def initialize(user:, packing_list: nil, params: nil, template_id: nil)
    @user = user
    @params = params
    # 編集時は渡されたpacking_listを使い、新規作成時はユーザーの空リストを用意する
    @packing_list = packing_list || user.packing_lists.build

    apply_template(template_id)
  end

  def save
    assign_attributes_from_params if @params.present?
    packing_list.assign_owner_to_new_items!(@user)
    packing_list.save
  end

  private

  def apply_template(template_id)
    return if template_id.blank?
    return unless packing_list.new_record?

    packing_list.apply_template_from_id(template_id)
  end

  def assign_attributes_from_params
    raw = @params.require(:packing_list)

    safe = raw.permit(:title, :festival_day_id).to_h
    safe[:packing_list_items_attributes] = sanitize_items_params(raw[:packing_list_items_attributes])
    packing_list.assign_attributes(safe)
  end

  # 持ち物リストフォームのネスト属性を正規化
  def sanitize_items_params(raw_items)
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
