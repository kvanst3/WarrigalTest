require 'open-uri'
require 'json'
require 'net/http'
require 'uri'
require "rubygems"

class MoviesController < ApplicationController
  before_action :authenticate_user!

  # show all movies in one's library
  def index
    @movies = current_user.movies
  end

  # displays series' episodes with torrent & subtitles
  def show
    @movie = Movie.find(params[:id])
    @serie = Serie.where(movie_id: @movie)
  end

  def create
    @movie = ::Movies::Creator::Create.new(current_user, params).call
    if @movie.save && @movie.is_movie?
      redirect_to movies_path
    elsif @movie.save
      redirect_to series_path(omdb_id: @movie.movie_id)
    else
      render :root
    end
  end

  def destroy
    @movie = current_user.movies.find(params[:id])
    @movie.destroy
    redirect_to movies_path
  end

  private

  # allow imdb id to reach controller
  # def id_params
  #   params.permit(:id)
  # end

  def valid_json?(string)
    !!JSON.parse(string)
  rescue JSON::ParserError
    false
  end
end
