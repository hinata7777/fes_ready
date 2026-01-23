module Festivals
  class ListQuery
    def self.call(status:, reference_date: Date.current, scope: Festival.all)
      new(status: status, reference_date: reference_date, scope: scope).call
    end

    def self.default_status
      Festival.status_filters.keys.first
    end

    def self.normalized_status(value)
      candidate = value.to_s
      Festival.status_filters.key?(candidate) ? candidate : default_status
    end

    def initialize(status:, reference_date:, scope:)
      @status = status
      @reference_date = reference_date
      @scope = scope
    end

    def call
      normalized = self.class.normalized_status(@status)
      status_scope = apply_status_scope(normalized)
      # 開催済みは新しい日付を上、開催前は古い日付を上に並べる。
      status_scope.order(start_date: order_direction(normalized), name: :asc)
    end

    private

    def apply_status_scope(normalized)
      normalized == "past" ? @scope.past(@reference_date) : @scope.upcoming(@reference_date)
    end

    def order_direction(normalized)
      normalized == "past" ? :desc : :asc
    end
  end
end
