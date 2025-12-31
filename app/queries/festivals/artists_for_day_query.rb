module Festivals
  class ArtistsForDayQuery
    def self.call(festival:, festival_day:)
      new(festival: festival, festival_day: festival_day).call
    end

    def initialize(festival:, festival_day:)
      @festival = festival
      @festival_day = festival_day
    end

    def call
      return Artist.none if @festival_day.blank? || @festival_day.festival_id != @festival.id

      Artist
        .joins(stage_performances: :festival_day)
        .where(stage_performances: { festival_day_id: @festival_day.id })
        .merge(Artist.published)
        .distinct
        # 表示用にアーティスト名で並べる
        .order(:name)
    end
  end
end
