module Festivals
  class StagePerformancesForDayQuery
    def self.call(festival:, festival_day:)
      new(festival: festival, festival_day: festival_day).call
    end

    def initialize(festival:, festival_day:)
      @festival = festival
      @festival_day = festival_day
    end

    def call
      return StagePerformance.none if @festival_day.blank?
      raise ArgumentError, "festival_day must belong to festival" if @festival_day.festival_id != @festival.id

      @festival_day.stage_performances
                   .includes(:stage, :artist)
                   # 表示用に開始時刻順
                   .order(:starts_at)
    end
  end
end
