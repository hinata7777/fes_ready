module Admin
  module StagePerformances
    class BulkForm
      ENTRY_LIMIT = 10

      # valid?/errorsなどActiveModelの振る舞いを使うため
      include ActiveModel::Model

      attr_reader :bulk_entries, :created_count
      # save内でvalid?を呼ぶときに実行する入力チェック
      validate :require_context
      validate :require_entries

      def initialize(permitted)
        @permitted = permitted
        @bulk_entries = nil
        @created_count = 0
      end

      def save
        @bulk_entries = build_bulk_entries(entry_attrs)

        return false unless valid?

        StagePerformance.transaction do
          usable_entries.each do |attrs|
            StagePerformance.create!(
              festival_day_id: @permitted[:festival_day_id],
              stage_id: @permitted[:stage_id],
              artist_id: attrs[:artist_id],
              starts_at: attrs[:starts_at],
              ends_at: attrs[:ends_at],
              status: attrs[:status].presence || :draft,
              canceled: normalize_canceled(attrs[:canceled])
            )
          end
        end

        @created_count = usable_entries.size
        true
      rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
        errors.add(:base, error_message_for(e))
        false
      end

      def self.empty_entries
        Array.new(ENTRY_LIMIT) { StagePerformance.new(status: :draft) }
      end

      private

      # entries を配列に揃え、各行をシンボルキーのハッシュに正規化する
      def normalize_entries(entries_param)
        return [] if entries_param.blank?

        raw_entries = case entries_param
        when Array
                        entries_param
        when ActionController::Parameters
                        entries_param.to_h.values
        else
                        []
        end

        raw_entries.map { |attrs| attrs.to_h.symbolize_keys }
      end

      def entry_attrs
        @entry_attrs ||= normalize_entries(@permitted[:entries])
      end

      def usable_entries
        @usable_entries ||= entry_attrs.select { |attrs| attrs[:artist_id].present? }
      end

      # エラー時の再表示用に、入力済み行+空行で10件分のモデルを作る
      def build_bulk_entries(entries)
        filled = entries.presence || []
        entries_as_models = filled.map { |attrs| StagePerformance.new(attrs) }
        padding = [ ENTRY_LIMIT - entries_as_models.size, 0 ].max
        entries_as_models + Array.new(padding) { StagePerformance.new(status: :draft) }
      end

      # canceled の入力値を true/false に整える（未入力は false）
      def normalize_canceled(value)
        casted = ActiveModel::Type::Boolean.new.cast(value)
        casted.nil? ? false : casted
      end

      # 例外の種類に応じてユーザー向けメッセージを作る
      def error_message_for(error)
        return friendly_pg_error(error) if error.is_a?(ActiveRecord::StatementInvalid)

        error.record&.errors&.full_messages&.first || "保存に失敗しました。"
      end

      # DB制約エラーの内容から分かりやすい文言に置き換える
      def friendly_pg_error(error)
        msg = error.message
        return "同一ステージで時間帯が重複しています（確定枠）。時間を見直してください。" if msg.include?("no_overlap_on_same_stage_when_scheduled")
        return "同一スロットの二重登録です（確定枠）。開始時刻・ステージ・アーティストの組み合わせを見直してください。" if msg.include?("uniq_sp_slot_when_scheduled")
        "保存に失敗しました（DB制約）。入力内容を確認してください。"
      end

      def require_context
        errors.add(:base, "開催日を選択してください。") if @permitted[:festival_day_id].blank?
        errors.add(:base, "ステージを選択してください。") if @permitted[:stage_id].blank?
      end

      def require_entries
        errors.add(:base, "1行以上入力してください。") if usable_entries.empty?
      end
    end
  end
end
