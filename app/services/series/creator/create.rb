module Series
  module Creator
    class Create

      def initialize(current_user, params)
        @current_user = current_user
        @omdb_id = params
        @serie_array = []
        @serie_subtitle = {}
        @id_movie = Movie.where(movie_id: @omdb_id).ids.last
      end

      def call
        if tracker_response != nil
          fill_serie_array
        else
          return redirect_to movie_path(@id_movie)
        end

        fill_subtitles_hash

        create_each_episode
      end

      private

      def tracker_response
        # parse tracker response
        tracker_tv = "https://tv-v2.api-fetch.website/show/" + @omdb_id
        @tracker_response ||= JSON.parse(open(tracker_tv).read)
      end

      def fill_serie_array
        i = tracker_response['episodes'].count
        j = 0
        while j < i do
          @serie_array << [tracker_response['episodes'][j]['season'], tracker_response['episodes'][j]['episode'], tracker_response['episodes'][j]['torrents']['0']['url'], tracker_response['episodes'][j]['title'], tracker_response['episodes'][0]['torrents']['0']['provider']]
          j += 1
        end
        # sort array - tracker info not sorted by default
        @serie_array.sort!
      end

      def number_of_seasons
        url = "https://www.omdbapi.com/?i=#{@omdb_id}&apikey=#{ENV['OMDB_KEY']}"
        result = JSON.parse(open(url).read)
        @number_of_seasons ||= result['totalSeasons'].to_i
      end

      def fill_subtitles_hash
        season_number = 1
        while season_number <= number_of_seasons do
          episode_number = 1
          # 30 used as arbitrary number since I couldn't find the number of episode per season without another scrape/api call
          while episode_number < 30
            # get subtitles based on language prefrence
            uri = URI.parse("https://rest.opensubtitles.org/search/episode-#{episode_number}/imdbid-#{(@omdb_id)[2..-1]}/season-#{season_number}/sublanguageid-#{@current_user.language == "EN" ? "eng" : "fre"}")
            request = Net::HTTP::Get.new(uri)
            request["X-User-Agent"] = "TemporaryUserAgent"

            req_options = {
              use_ssl: uri.scheme == "https",
            }

            response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
              http.request(request)
            end

            parsed_response = JSON.parse(response.body)
            sub_url = parsed_response[0]["SubDownloadLink"] if parsed_response.present?
            break if (sub_url == @serie_subtitle.values.last) && (@serie_subtitle.count > 1)
            episode_number += 1
            # returns a unique id for subtitles to match them with episodes (e.g: 1|11 for season 1 episode 11)
            @serie_subtitle[parsed_response[0]["QueryParameters"]["season"].to_s + '|' + parsed_response[0]["QueryParameters"]["episode"].to_s] = sub_url
          end
          season_number += 1
        end
      end

      def create_each_episode
        i = 0
        while i < @serie_array.count
          # returns a unique id for episodes to match them with subtitles (e.g: 1|11 for season 1 episode 11)
          current_episode = @serie_array[i][0].to_s + '|' + @serie_array[i][1].to_s
          @serie = Serie.new(
            season: @serie_array[i][0],
            episode: @serie_array[i][1],
            magnet: @serie_array[i][2],
            title: @serie_array[i][3],
            subtitle: @serie_subtitle[current_episode]
          )
          # associate logged in user to movie for personalised library
          @serie.movie_id = @id_movie
          # save in DB
          if @serie.save
            i += 1
          else
            render :root
          end
        end
      end

    end
  end
end



