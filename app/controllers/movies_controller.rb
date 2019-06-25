require 'open-uri'
require 'json'

class MoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    @movies = Movie.all
  end

  def create
    movie_id = id_params[:id]
    url = "http://www.omdbapi.com/?i=#{movie_id}&apikey=#{ENV['OMDB_KEY']}"
    result = JSON.parse(open(url).read)
    @movie = Movie.new(
      name: result["Title"],
      stars: result["Ratings"][0]["Value"],
      director: result["Director"],
      url: result["Poster"]
    )
    @movie.user = current_user
    if @movie.save
      redirect_to movies_path
    else
      raise
    end
  end

  private

  def id_params
    params.permit(:id)
  end
end
