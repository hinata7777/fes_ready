module Admin
  module Setlists
    class FormBuilder
      ENTRY_LIMIT = 20

      def self.build(setlist, limit: ENTRY_LIMIT)
        new(setlist, limit: limit).build
      end

      def initialize(setlist, limit:)
        @setlist = setlist
        @limit = limit
      end

      def build
        # nilが紛れ込んでいる場合を排除
        setlist.setlist_songs.target.compact!

        (1..limit).each do |pos|
          setlist.setlist_songs.build(position: pos) unless setlist.setlist_songs.any? { |s| s.position == pos }
        end
      end

      private

      attr_reader :setlist, :limit
    end
  end
end
