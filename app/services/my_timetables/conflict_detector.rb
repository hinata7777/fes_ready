module MyTimetables
  class ConflictDetector
    def self.call(list)
      conflicts = Set.new
      last_end = nil
      last_id  = nil
      list.each do |sp|
        if last_end && sp.starts_at && sp.ends_at && sp.starts_at < last_end
          conflicts << last_id
          conflicts << sp.id
        end
        last_end = sp.ends_at || last_end
        last_id  = sp.id
      end
      conflicts
    end
  end
end
