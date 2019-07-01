module Movies
  module Creator
    class Create

      def initialize(current_user, params)
        @current_user = current_user
        @params = params
      end

      def call
        current_user.movies.new(
          name: omnidb_api_result["Title"],
          stars: omnidb_api_result["Ratings"][0]["Value"],
          director: omnidb_api_result["Director"],
          url: omnidb_api_result["Poster"],
          movietype: omnidb_api_result["Type"],
          movie_id: params[:id],
          seed: torrent_info["seed"],
          peer: torrent_info["peer"],
          filesize: torrent_info["filesize"],
          provider: torrent_info["provider"],
          magnet: torrent_info["url"],
          subtitle: subtitle_url
        )
      end

      private

      attr_reader :current_user, :params

      def torrent_info
        @torrent_info ||= GetTorrentInfo.new(params[:id]).call
      end

      def omnidb_api_result
        url = "https://www.omdbapi.com/?i=#{params[:id]}&apikey=#{ENV['OMDB_KEY']}"
        JSON.parse(open(url).read)
      end

      def subtitle_url
        if omnidb_api_result["Type"] == "movie"
          uri = URI.parse("https://rest.opensubtitles.org/search/imdbid-#{(params[:id])[2..-1]}/sublanguageid-#{current_user.language == "EN" ? "eng" : "fre"}")

          request = Net::HTTP::Get.new(uri)
          request["X-User-Agent"] = "TemporaryUserAgent"

          req_options = {
            use_ssl: uri.scheme == "https",
          }

          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end
          parsed_response = JSON.parse(response.body)
          parsed_response[0]["SubDownloadLink"] if parsed_response.present?
        end
      end

    end
  end
end

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
# # associate logged in user to movie for personalised library
# ### @movie.user = current_user

# # allow imdb id to reach controller
# def id_params
#   params.permit(:id)
# end

# def valid_json?(string)
#   !!JSON.parse(string)
# rescue JSON::ParserError
#   false
# end
