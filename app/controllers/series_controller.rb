class SeriesController < ApplicationController
  def create
    @serie = ::Series::Creator::Create.new(current_user, params[:omdb_id]).call

    redirect_to movie_path(Movie.last)
  end
end
