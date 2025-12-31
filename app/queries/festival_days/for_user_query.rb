module FestivalDays
  class ForUserQuery
    def self.call(user:)
      new(user: user).call
    end

    def initialize(user:)
      @user = user
    end

    def call
      FestivalDay
        .joins(:festival, stage_performances: :user_timetable_entries)
        .where(user_timetable_entries: { user_id: @user.id })
        .includes(:festival)
        .distinct
        # 一覧表示で「フェス開始日 → 日程」の順に揃える
        .order("festivals.start_date ASC", "festival_days.date ASC")
    end
  end
end
