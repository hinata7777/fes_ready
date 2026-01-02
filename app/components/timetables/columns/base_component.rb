module Timetables
  module Columns
    class BaseComponent < ViewComponent::Base
      # 共通の入力だけを受け取り、描画は子のrender_blockに委譲する
      def initialize(stage:, performances:, time_markers:, timeline_layout:)
        @stage = stage
        @performances = Array(performances)
        @time_markers = Array(time_markers)
        @timeline_layout = timeline_layout
      end

      private

      attr_reader :stage, :performances, :time_markers

      def timeline_layout
        @timeline_layout || raise(ArgumentError, "timeline_layout is required")
      end

      # ブロック共通のコンテナクラス
      def default_block_classes
        "absolute inset-x-1.5 rounded-md px-2 py-1 text-[11px] font-semibold shadow-sm interactive-lift sm:inset-x-2 sm:px-3 sm:py-2 sm:text-xs"
      end

      # ブロックの位置・サイズ・色のインラインスタイル（必要なら枠線も追加）
      def block_style(block, background_color:, text_color:, border: nil)
        style_rules = [
          "top: #{block.top_percent}%;",
          "height: #{block.height_percent}%;",
          "background-color: #{background_color};",
          "color: #{text_color};"
        ]
        style_rules << "border: #{border};" if border
        style_rules.join(" ")
      end

      # ブロックの基本表示（時間ラベル + アーティスト名）。キャンセル表示も対応
      def default_block_content(block, artist_name, canceled: false)
        canceled_classes = canceled ? "text-red-700 line-through decoration-2" : nil
        time_label = block.end_label ? "#{block.start_label}-#{block.end_label}" : block.start_label

        time_block = content_tag(:div,
                                 content_tag(:div, time_label, class: "whitespace-nowrap"),
                                 class: [ "font-mono text-[9px] font-medium leading-none opacity-90 sm:text-[10px]", canceled_classes ].compact.join(" "))

        name_block = content_tag(:div,
                                 artist_name,
                                 class: [ "flex-1 overflow-hidden text-ellipsis text-[11px] font-bold leading-tight sm:text-xs", canceled_classes ].compact.join(" "))

        content_tag(:div, class: "flex h-full flex-col justify-start gap-px text-left") do
          safe_join([ time_block, name_block ])
        end
      end

      # キャンセル表示かどうかを判定
      def canceled?(performance)
        performance.respond_to?(:canceled?) && performance.canceled?
      end

      # ステージ背景色をキャッシュ
      def stage_color
        @stage_color ||= stage.color_hex
      end

      # 背景色に応じた文字色をキャッシュ
      def stage_text_color
        @stage_text_color ||= helpers.stage_text_color(stage_color)
      end

      # ステージヘッダーの背景色と文字色をまとめたstyle
      def stage_header_style
        "background-color: #{stage_color}; color: #{stage_text_color};"
      end

      # タイムラインの高さを固定するためのstyle
      def timeline_body_style
        "height: #{timeline_layout.column_height_px}px;"
      end

      # マーカー線用の位置情報を取得
      def marker_lines
        timeline_layout.marker_lines(time_markers)
      end

      # 描画対象のブロックとパフォーマンスをペアで返す
      def performance_blocks
        performances.filter_map do |performance|
          block = timeline_layout.performance_block(performance)
          next unless block
          [ performance, block ]
        end
      end

      # ブロック描画は呼び出し側に委譲
      def render_block(_performance, _block)
        raise NotImplementedError, "Subclasses must implement #render_block"
      end
    end
  end
end
