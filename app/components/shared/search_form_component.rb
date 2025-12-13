module Shared
  class SearchFormComponent < ViewComponent::Base
    def initialize(query:, url:, placeholder: "", status: nil, hidden_fields: {})
      @query = query
      @url = url
      @placeholder = placeholder
      @status = status
      @hidden_fields = hidden_fields.compact
    end

    def call
      helpers.search_form_for(query, url: url, method: :get, html: { class: "mb-6" }) do |f|
        content_tag(:div, class: "flex flex-nowrap items-center gap-2") do
          safe_join([ status_field, hidden_field_elements, search_input(f), submit_button(f) ].compact)
        end
      end
    end

    private

    attr_reader :query, :url, :placeholder, :status, :hidden_fields

    def status_field
      return unless status.present?

      helpers.hidden_field_tag(:status, status)
    end

    def hidden_field_elements
      return if hidden_fields.blank?

      fields = hidden_fields.flat_map do |key, value|
        Array(value).compact_blank.map do |val|
          helpers.hidden_field_tag(key, val)
        end
      end
      safe_join(fields)
    end

    def search_input(form_builder)
      form_builder.search_field(:name_i_cont,
                                class: "h-12 w-full flex-1 rounded-lg border border-slate-300 bg-white px-4 text-slate-700 shadow-sm transition focus:border-indigo-400 focus:outline-none focus:ring-2 focus:ring-indigo-200 placeholder:text-slate-400",
                                placeholder: placeholder)
    end

    def submit_button(form_builder)
      form_builder.submit("検索",
                          class: "inline-flex h-12 min-w-[90px] flex-shrink-0 items-center justify-center rounded-lg bg-gradient-to-r from-indigo-500 to-violet-500 px-4 text-sm font-semibold text-white shadow-sm interactive-lift hover:from-indigo-600 hover:to-violet-600 focus:outline-none focus:ring-2 focus:ring-indigo-200 whitespace-nowrap",
                          data: { controller: "tap-feedback" })
    end
  end
end
