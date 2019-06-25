require 'open-uri'
require 'json'

class MoviesController < ApplicationController
  before_action :authenticate_user!

  # show all selected movies
  def index
    @movies = Movie.all
  end

  def show
    @movie = Movie.find(params[:id])
  end

  def create
    # Gets the IMDB id
    movie_id = id_params[:id]
    # Gets the torrent informations - returns a hash with url, seed, peer, filesize and provider
    torrent = "https://tv-v2.api-fetch.website/movie/" + movie_id
    if valid_json?(open(torrent).read)
      torrent_result = JSON.parse(open(torrent).read)
      torrent_info = torrent_result["torrents"].first[1].first[1]
    else
      torrent_info = {"provider"=>"n/a", "filesize"=>"n/a", "size"=>0, "peer"=>0, "seed"=>0, "url"=>"#"}
      trackerTV = "https://tv-v2.api-fetch.website/show/" + movie_id
      # if valid_json?(open(trackerTV).read)
      #   torrent_result = JSON.parse(open(trackerTV).read)
      #   raise
      # end
    end

    # fetches info from omdbapi - redundant due to info present in earlier call (requirement)
    url = "http://www.omdbapi.com/?i=#{movie_id}&apikey=#{ENV['OMDB_KEY']}"
    result = JSON.parse(open(url).read)
    @movie = Movie.new(
      name: result["Title"],
      stars: result["Ratings"][0]["Value"],
      director: result["Director"],
      url: result["Poster"],
      movietype: result["Type"],
      movieid: movie_id,
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

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    redirect_to movies_path
  end

  private

  # allow imdb id to reach controller
  def id_params
    params.permit(:id)
  end

  def valid_json?(string)
    !!JSON.parse(string)
  rescue JSON::ParserError
    false
  end
end
