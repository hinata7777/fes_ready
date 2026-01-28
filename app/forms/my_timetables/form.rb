module MyTimetables
  class Form
    include ActiveModel::Model

    def initialize(user:, festival_day:, stage_performance_ids:)
      @user = user
      @festival_day = festival_day
      @stage_performance_ids = Array(stage_performance_ids).map(&:to_i)
    end

    def save
      ActiveRecord::Base.transaction do
        delete_existing_entries
        filtered_ids.each do |stage_performance_id|
          user.user_timetable_entries.create!(stage_performance_id: stage_performance_id)
        end
      end

      true
    rescue StandardError => e
      message =
        if e.respond_to?(:record) && e.record.respond_to?(:errors) && e.record.errors.any?
          e.record.errors.full_messages.to_sentence
        else
          "保存に失敗しました。"
        end
      errors.add(:base, message)
      false
    end

    private

    attr_reader :user, :festival_day, :stage_performance_ids

    def delete_existing_entries
      # 対象日の既存の選択を一度削除してから入れ替える
      MyTimetables::EntriesForDayQuery.call(user: user, festival_day: festival_day).delete_all
    end

    def filtered_ids
      allowed_ids = StagePerformance.where(festival_day_id: festival_day.id).pluck(:id)
      (stage_performance_ids & allowed_ids).uniq
    end
  end
end
