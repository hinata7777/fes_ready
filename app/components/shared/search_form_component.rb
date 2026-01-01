module Shared
  class SearchFormComponent < ViewComponent::Base
    def initialize(query:, url:, placeholder: "", status: nil, hidden_fields: {})
      @query = query
      @url = url
      @placeholder = placeholder
      @status = status
      @hidden_fields = hidden_fields.compact
    end

    private

    attr_reader :query, :url, :placeholder, :status, :hidden_fields

    def status?
      status.present?
    end

    def hidden_field_pairs
      hidden_fields.flat_map do |key, value|
        Array(value).compact_blank.map { |val| [ key, val ] }
      end
    end

    def placeholder_value
      placeholder
    end
  end
end
