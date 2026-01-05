module Admin
  module PackingLists
    class ParamsSanitizer
      def self.call(raw_items)
        return [] if raw_items.blank?

        # 動的キー付きの入力をハッシュ配列に正規化する
        raw_items.to_unsafe_h.map do |_, attrs|
          attrs = attrs.to_unsafe_h if attrs.respond_to?(:to_unsafe_h)
          next unless attrs.is_a?(Hash)

          # 保存に必要なキーだけを抽出する
          attrs.slice("id", "item_id", "note", "position", "_destroy")
        end.compact
      end
    end
  end
end
