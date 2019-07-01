require 'open-uri'
require 'json'
require 'net/http'
require 'uri'
require "rubygems"

class MoviesController < ApplicationController
  before_action :authenticate_user!

  # show all movies in one's library
  def index
    @movies = Movie.where(user_id: current_user)
  end
  #displays series' episodes with torrent & subtitles
  def show
    @movie = Movie.find(params[:id])
    @serie = Serie.where(movie_id: @movie)
  end

  def create
    # @movie = ::Movies::Creator::Create.new(current_user, params).call
    # # Gets the IMDB id
    # movie_id = id_params[:id]
    # # Gets the torrent informations - returns a hash with url, seed, peer, filesize and provider
    # torrent = "https://tv-v2.api-fetch.website/movie/" + movie_id
    # if valid_json?(open(torrent).read)
    #   torrent_result = JSON.parse(open(torrent).read)
    #   torrent_info = torrent_result["torrents"].first[1].first[1]
    # else
    #   torrent_info = {"provider"=>"n/a", "filesize"=>"n/a", "size"=>0, "peer"=>0, "seed"=>0, "url"=>"#"}
    #   trackerTV = "https://tv-v2.api-fetch.website/show/" + movie_id
    # end

    # # fetches info from omdbapi
    # url = "https://www.omdbapi.com/?i=#{movie_id}&apikey=#{ENV['OMDB_KEY']}"
    # result = JSON.parse(open(url).read)

    # #Fetch subtitles
    # if result["Type"] == "movie"
    #   uri = URI.parse("https://rest.opensubtitles.org/search/imdbid-#{(movie_id)[2..-1]}/sublanguageid-#{current_user.language == "EN" ? "eng" : "fre"}")

    #   request = Net::HTTP::Get.new(uri)
    #   request["X-User-Agent"] = "TemporaryUserAgent"

    #   req_options = {
    #     use_ssl: uri.scheme == "https",
    #   }

    #   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #     http.request(request)
    #   end
    #   parsed_response = JSON.parse(response.body)
    #   subtitle_url = parsed_response[0]["SubDownloadLink"] if parsed_response.present?

    # end

    # #Add to DB
    # @movie = current_user.movies.new(
    #   name: result["Title"],
    #   stars: result["Ratings"][0]["Value"],
    #   director: result["Director"],
    #   url: result["Poster"],
    #   movietype: result["Type"],
    #   movie_id: movie_id,
    #   seed: torrent_info["seed"],
    #   peer: torrent_info["peer"],
    #   filesize: torrent_info["filesize"],
    #   provider: torrent_info["provider"],
    #   magnet: torrent_info["url"],
    #   subtitle: subtitle_url
    # )
    # associate logged in user to movie for personalised library
    ### @movie.user = current_user
    # save in DB
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
    @movie = Movie.find(params[:id])
    @movie.destroy if @movie.user == current_user
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
