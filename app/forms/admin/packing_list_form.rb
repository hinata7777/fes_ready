module Admin
  class PackingListForm
    include ActiveModel::Model

    attr_reader :packing_list

    def initialize(packing_list: nil, params: nil)
      # 編集時は渡されたpacking_listを使い、新規作成時は空のテンプレートを用意する
      @packing_list = packing_list || PackingList.new(template: true, user: nil)
      @params = params
    end

    def save
      assign_attributes_from_params if @params.present?
      # 管理画面はテンプレートのみ扱う前提だが、念のためテンプレ属性を強制する
      packing_list.template = true
      packing_list.user = nil
      packing_list.save
    end

    private

    def assign_attributes_from_params
      raw = @params.require(:packing_list)

      safe = raw.permit(:title, :festival_day_id).to_h
      safe[:packing_list_items_attributes] = sanitize_items_params(raw[:packing_list_items_attributes])
      packing_list.assign_attributes(safe)
    end

    # 管理画面用のネスト属性は既存item参照のみ許可
    def sanitize_items_params(raw_items)
      return [] if raw_items.blank?

      raw_items.to_unsafe_h.map do |_, attrs|
        attrs = attrs.to_unsafe_h if attrs.respond_to?(:to_unsafe_h)
        next unless attrs.is_a?(Hash)

        attrs.slice("id", "item_id", "note", "position", "_destroy")
      end.compact
    end
  end
end
