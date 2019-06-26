require 'open-uri'
require 'json'
require 'net/http'
require 'uri'
require "rubygems"

class MoviesController < ApplicationController
  before_action :authenticate_user!

  # show all selected movies
  def index
    @movies = Movie.all
  end

  def show
    @movie = Movie.find(params[:id])
    url = "http://www.omdbapi.com/?i=#{@movie.movieid}&apikey=#{ENV['OMDB_KEY']}"
    result = JSON.parse(open(url).read)
    number_seasons = result['totalSeasons'].to_i

    @serie_subs = {}
    i = 1
    while i <= number_seasons do
      j = 1
      response = 1
      while j < 20
        uri = URI.parse("https://rest.opensubtitles.org/search/episode-#{j}/imdbid-#{(@movie.movieid)[2..-1]}/season-#{i}/tags-web-dl")

        request = Net::HTTP::Get.new(uri)
        request["X-User-Agent"] = "TemporaryUserAgent"

        req_options = {
          use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        better = JSON.parse(response.body)
        sub_url = better[0]["SubDownloadLink"] if better.present?
        break if (sub_url == @serie_subs.values.last) && (@serie_subs.count > 1)
        j += 1
        @serie_subs[better[0]["QueryParameters"]["season"].to_s + better[0]["QueryParameters"]["episode"].to_s] = sub_url
      end
      i += 1
    end
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

    #Fetch subtitles
    if result["Type"] == "movie"
      uri = URI.parse("https://rest.opensubtitles.org/search/imdbid-#{(movie_id)[2..-1]}/sublanguageid-eng")

      request = Net::HTTP::Get.new(uri)
      request["X-User-Agent"] = "TemporaryUserAgent"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      better = JSON.parse(response.body)
      sub_url = better[0]["SubDownloadLink"] if better.present?

    end

    #Add to DB
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
      magnet: torrent_info["url"],
      subtitle: sub_url
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
