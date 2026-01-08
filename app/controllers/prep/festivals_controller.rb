module Prep
  class FestivalsController < ApplicationController
    include HeaderBackPath
    def index
      @status = Festivals::ListQuery.normalized_status(params[:status])
      @festival_tags = FestivalTag.order(:name)
      @filter_params = Festivals::FilterQuery.permitted_params(params)
      @selected_tag_ids = Array(@filter_params[:tag_ids]).reject(&:blank?).map(&:to_i)

      scoped = Festivals::ListQuery.call(status: @status)
      filtered_scope = Festivals::FilterQuery.call(scope: scoped, filters: @filter_params)

      @q = filtered_scope.ransack(params[:q])
      result = @q.result(distinct: true)

      pagy_params = request.query_parameters.merge(status: @status)
      @pagy, @festivals = pagy(result, limit: 20, params: pagy_params)

      prepare_index_view_context
    end

    def show
      @festival = find_festival
      @festival_days = @festival.timetable_days
      @selected_day = @festival.select_day(params[:date], days: @festival_days)
      entries = Prep::FestivalSongEntriesBuilder.build(festival: @festival, selected_day: @selected_day)
      @pagy, @song_entries = pagy_array(entries, limit: 10, page: params[:page])
      set_header_back_path
    end

    private

    def find_festival
      festival_relation = Festival.includes(:festival_days)
      Festival.find_by_slug!(params[:id], scope: festival_relation)
    end

    def prepare_index_view_context
      # TODO: 画面ロジックが増えたらViewContext/Presenterに移す
      @preserved_query = request.query_parameters.except(:page, :status)
      @tab_url_builder = ->(key) { prep_festivals_path(@preserved_query.merge(status: key)) }
      @search_query = params.dig(:q, :name_i_cont)
      @hidden_filter_fields = {
        start_date_from: @filter_params[:start_date_from],
        end_date_to: @filter_params[:end_date_to],
        area: @filter_params[:area],
        "tag_ids[]": @selected_tag_ids
      }
      @reset_params = { status: @status }
      @reset_params[:q] = { name_i_cont: @search_query } if @search_query.present?
      @reset_url = prep_festivals_path(@reset_params)
    end

    def resolved_back_path(token)
      # "festival" トークンは対象フェスの詳細へ戻す
      return festival_path(@festival) if token == "festival" && @festival
      nil
    end
  end
end
