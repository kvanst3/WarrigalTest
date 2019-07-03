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
