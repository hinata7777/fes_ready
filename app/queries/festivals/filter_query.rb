module Festivals
  # 一覧検索の共通フィルタをまとめる
  class FilterQuery
    def self.call(scope:, filters:)
      new(scope: scope, filters: filters).call
    end

    def self.permitted_params(params)
      params.permit(:start_date_from, :end_date_to, :area, tag_ids: [])
    end

    def initialize(scope:, filters:)
      @scope = scope
      @filters = filters
    end

    def call
      filtered = @scope

      from_date = parse_date(@filters[:start_date_from])
      to_date   = parse_date(@filters[:end_date_to])

      filtered = filtered.where("start_date >= ?", from_date) if from_date
      filtered = filtered.where("end_date <= ?", to_date) if to_date

      if @filters[:area].present? && Regions::AREA_PREFECTURES.key?(@filters[:area])
        prefectures = Regions::AREA_PREFECTURES[@filters[:area]]
        filtered = filtered.where(prefecture: prefectures)
      end

      tag_ids = Array(@filters[:tag_ids]).reject(&:blank?).map(&:to_i)
      if tag_ids.any?
        filtered = filtered
                     .joins(:festival_festival_tags)
                     .where(festival_festival_tags: { festival_tag_id: tag_ids })
                     .group("festivals.id")
                     .having("COUNT(DISTINCT festival_festival_tags.festival_tag_id) = ?", tag_ids.size)
      end

      filtered
    end

    private

    def parse_date(value)
      return if value.blank?
      Date.parse(value)
    rescue ArgumentError
      nil
    end
  end
end
