module Shared
  class NavStackButtonComponent < ViewComponent::Base
    def initialize(label:, url: nil, subtext: nil, tags: nil, trailing: nil, disabled: false, data: nil)
      @label = label
      @url = url
      @subtext = subtext
      @tags = tags
      @trailing = trailing
      @disabled = disabled
      @data = data
    end

    private

    attr_reader :label, :url, :subtext, :tags, :trailing, :data

    def disabled?
      !!@disabled
    end

    def wrapper_tag
      disabled? ? :div : :a
    end

    def wrapper_options
      classes = "nav-stack-button interactive-lift"
      return { class: "#{classes} opacity-50 cursor-not-allowed", "aria-disabled": "true" } if disabled?

      merged_data = { controller: "tap-feedback" }.merge(data || {})
      { class: classes, href: url, data: merged_data }
    end
  end
end
