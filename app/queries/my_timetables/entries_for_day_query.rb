module MyTimetables
  class EntriesForDayQuery
    def self.call(user:, festival_day:)
      new(user: user, festival_day: festival_day).call
    end

    def initialize(user:, festival_day:)
      @user = user
      @festival_day = festival_day
    end

    def call
      user.user_timetable_entries
          .joins(:stage_performance)
          .where(stage_performances: { festival_day_id: festival_day.id })
    end

    private

    attr_reader :user, :festival_day
  end
end
