module Shared
  class SegmentedTabsComponent < ViewComponent::Base
    # tabs: { タブのキー => 表示ラベル } を想定したハッシュ
    def initialize(tabs:, active_tab_key:, url_builder:)
      @tabs = tabs
      @active_tab_key = active_tab_key
      @url_builder = url_builder
    end

    private

    attr_reader :tabs, :active_tab_key, :url_builder

    def tab_items
      tabs.to_a
    end

    def url_for_key(key)
      url_builder.respond_to?(:call) ? url_builder.call(key) : url_builder
    end
  end
end
