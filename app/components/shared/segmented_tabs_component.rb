module Shared
  class SegmentedTabsComponent < ViewComponent::Base
    # tabs: { タブのキー => 表示ラベル } を想定したハッシュ
    def initialize(tabs:, active_tab_key:, url_builder:)
      @tabs = tabs
      @active_tab_key = active_tab_key
      @url_builder = url_builder
    end

    def call
      content_tag(:div, class: "inline-flex rounded-xl bg-white p-1 shadow-md") do
        safe_join(tabs.map { |key, label| tab_link(key, label) })
      end
    end

    private

    attr_reader :tabs, :active_tab_key, :url_builder

    def tab_link(key, label)
      active = key == active_tab_key
      classes = [
        "rounded-lg px-4 py-2 text-sm font-semibold transition",
        active ? "bg-rose-500 text-white shadow-sm" : "text-slate-500 hover:text-rose-500"
      ].join(" ")

      link_to(label,
              url_for_key(key),
              class: classes)
    end

    def url_for_key(key)
      url_builder.respond_to?(:call) ? url_builder.call(key) : url_builder
    end
  end
end
