module Admin
  module Songs
    class BulkForm
      ENTRY_LIMIT = 10

      include ActiveModel::Model

      attr_reader :bulk_entries, :created_count
      # save内でvalid?を呼ぶときに実行する入力チェック
      validate :require_entries

      def initialize(permitted)
        @permitted = permitted
        @bulk_entries = nil
        @created_count = 0
      end

      def save
        @bulk_entries = self.class.build_entries(entry_attrs)
        return false unless valid?

        Song.transaction do
          usable_entries.each do |attrs|
            Song.create!(attrs)
          end
        end

        @created_count = usable_entries.size
        true
      rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
        errors.add(:base, e.record&.errors&.full_messages&.first || "保存に失敗しました。")
        false
      end

      def self.empty_entries
        build_entries([])
      end

      def self.build_entries(entries)
        filled = entries.presence || []
        padding = [ ENTRY_LIMIT - filled.size, 0 ].max
        filled + Array.new(padding) { { name: nil, spotify_id: nil, artist_id: nil } }
      end

      private

      def entry_attrs
        @entry_attrs ||= normalize_entries(@permitted[:entries])
      end

      def usable_entries
        @usable_entries ||= entry_attrs.select { |attrs| attrs[:name].present? && attrs[:artist_id].present? }
      end

      def normalize_entries(entries)
        return [] if entries.blank?

        entries.map do |attrs|
          attrs = attrs.to_h.symbolize_keys
          next if ActiveModel::Type::Boolean.new.cast(attrs[:_destroy])
          {
            name: attrs[:name].to_s.strip,
            spotify_id: attrs[:spotify_id].presence,
            artist_id: attrs[:artist_id].presence
          }
        end.compact
      end

      def require_entries
        errors.add(:base, "1行以上入力してください。") if usable_entries.empty?
      end
    end
  end
end
