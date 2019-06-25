require 'open-uri'
require 'json'

class MoviesController < ApplicationController
  before_action :authenticate_user!

  # show all selected movies
  def index
    @movies = Movie.all
  end

  def create
    # Gets the IMDB id
    movie_id = id_params[:id]
    # Gets the torrent informations - returns a hash with url, seed, peer, filesize and provider
    torrent = "https://tv-v2.api-fetch.website/movie/" + movie_id
    torrent_result = JSON.parse(open(torrent).read)
    torrent_info = torrent_result["torrents"].first[1].first[1]

    # fetches info from omdbapi - redundant due to info present in earlier call (requirement)
    url = "http://www.omdbapi.com/?i=#{movie_id}&apikey=#{ENV['OMDB_KEY']}"
    result = JSON.parse(open(url).read)
    @movie = Movie.new(
      name: result["Title"],
      stars: result["Ratings"][0]["Value"],
      director: result["Director"],
      url: result["Poster"],
      seed: torrent_info["seed"],
      peer: torrent_info["peer"],
      filesize: torrent_info["filesize"],
      provider: torrent_info["provider"],
      magnet: torrent_info["url"]
    )
    # associate logged in user to movie for personalised library
    @movie.user = current_user
    # save in DB
    if @movie.save
      redirect_to movies_path
    else
      raise
    end
  end

  private

  # allow params to reach controller
  def id_params
    params.permit(:id)
  end
end
