module SearchFiltersHelper
  def preserved_query_params
    request.query_parameters.except(:page, :status)
  end

  def name_search_query
    params.dig(:q, :name_i_cont)
  end

  def hidden_filter_fields(filter_params:, selected_tag_ids:)
    {
      start_date_from: filter_params[:start_date_from],
      end_date_to: filter_params[:end_date_to],
      area: filter_params[:area],
      "tag_ids[]": selected_tag_ids
    }
  end

  def reset_params_with_query(status:, search_query:)
    params = { status: status }
    params[:q] = { name_i_cont: search_query } if search_query.present?
    params
  end
end
