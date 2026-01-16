module MyTimetables
  class ConflictDetector
    def self.call(list)
      new(list).call
    end

    def initialize(list)
      @list = list
    end

    def call
      conflicts = Set.new
      last_end = nil
      last_id  = nil
      sorted_list.each do |sp|
        has_times = last_end && sp.starts_at && sp.ends_at
        if has_times && sp.starts_at < last_end
          conflicts << last_id
          conflicts << sp.id
        end
        last_end = sp.ends_at || last_end
        last_id  = sp.id
      end
      conflicts
    end

    private

    attr_reader :list

    def sorted_list
      list.sort_by { |sp| [ time_key(sp.starts_at), time_key(sp.ends_at), sp.id ] }
    end

    def time_key(time)
      time || Time.at(0)
    end
  end
end
