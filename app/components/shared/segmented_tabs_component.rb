module Shared
  class SegmentedTabsComponent < ViewComponent::Base
    def initialize(items:, active_key:, url_builder:)
      @items = items
      @active_key = active_key
      @url_builder = url_builder
    end

    def call
      content_tag(:div, class: "inline-flex rounded-xl bg-white p-1 shadow-md") do
        safe_join(items.map { |key, label| tab_link(key, label) })
      end
    end

    private

    attr_reader :items, :active_key, :url_builder

    def tab_link(key, label)
      active = key == active_key
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
