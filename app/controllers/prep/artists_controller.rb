module Prep
  class ArtistsController < ApplicationController
    def index
      artists_scope = Artist.published.order(:name)
      @q     = artists_scope.ransack(params[:q])
      result = @q.result(distinct: true)

      @pagy, @artists = pagy(result, params: request.query_parameters)
    end
  end
end
