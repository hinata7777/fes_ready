module Admin
  module Setlists
    class Form
      ENTRY_LIMIT = 20

      attr_reader :setlist

      def initialize(setlist:, params: nil, limit: ENTRY_LIMIT)
        @setlist = setlist
        @params = params
        @limit = limit
      end

      def save
        assign_attributes_from_params if @params.present?
        setlist.save
      end

      def build_rows
        # nilが紛れ込んでいる場合を排除
        setlist.setlist_songs.target.compact!

        (1..@limit).each do |pos|
          setlist.setlist_songs.build(position: pos) unless setlist.setlist_songs.any? { |s| s.position == pos }
        end
      end

      private

      def assign_attributes_from_params
        raw = @params.require(:setlist).permit(
          :stage_performance_id,
          setlist_songs_attributes: %i[id song_id position note _destroy]
        )

        # 曲未選択の行は _destroy=1 にして無視する
        if raw[:setlist_songs_attributes].present?
          raw[:setlist_songs_attributes].each_value do |attrs|
            attrs[:_destroy] = "1" if attrs[:song_id].blank?
          end
        end

        setlist.assign_attributes(raw)
      end
    end
  end
end
