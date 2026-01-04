module Admin
  module Songs
    class BulkCreator
      ENTRY_LIMIT = 10
      Result = Struct.new(:created_count, :bulk_entries, :error_message, keyword_init: true) do
        def success?
          error_message.nil?
        end
      end

      def self.call(permitted)
        new(permitted).call
      end

      def self.empty_entries
        build_entries([])
      end

      def initialize(permitted)
        @permitted = permitted
      end

      def call
        entry_attrs = normalize_entries(@permitted[:entries])
        usable_entries = entry_attrs.select { |attrs| attrs[:name].present? && attrs[:artist_id].present? }

        if usable_entries.empty?
          return Result.new(
            created_count: 0,
            bulk_entries: self.class.build_entries(entry_attrs),
            error_message: "1行以上入力してください。"
          )
        end

        Song.transaction do
          usable_entries.each do |attrs|
            Song.create!(attrs)
          end
        end

        Result.new(created_count: usable_entries.size, bulk_entries: nil, error_message: nil)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
        Result.new(
          created_count: 0,
          bulk_entries: self.class.build_entries(entry_attrs),
          error_message: e.record&.errors&.full_messages&.first || "保存に失敗しました。"
        )
      end

      def self.build_entries(entries)
        filled = entries.presence || []
        # 入力済みの行を保持しつつ、足りない分だけ空行で埋める
        padding = [ ENTRY_LIMIT - filled.size, 0 ].max
        filled + Array.new(padding) { { name: nil, spotify_id: nil, artist_id: nil } }
      end

      private

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
    end
  end
end
