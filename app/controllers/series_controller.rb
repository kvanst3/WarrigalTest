class SeriesController < ApplicationController
  def create
    @omdb_id = params[:omdb_id]
    idmovie = Movie.where(movie_id: @omdb_id).ids.last

    seriearray = []
    # parse tracker response
    tracker_tv = "https://tv-v2.api-fetch.website/show/" + @omdb_id
    torrent_result = JSON.parse(open(tracker_tv).read)
    # if result, push to array
    if torrent_result != nil
      i = torrent_result['episodes'].count
      j = 0
      while j < i do
        seriearray << [torrent_result['episodes'][j]['season'], torrent_result['episodes'][j]['episode'], torrent_result['episodes'][j]['torrents']['0']['url'], torrent_result['episodes'][j]['title'], torrent_result['episodes'][0]['torrents']['0']['provider']]
        j += 1
      end
      # sort array - tracker info not sorted by default
      seriearray.sort!
    else
      return redirect_to movie_path(idmovie)
    end

    url = "https://www.omdbapi.com/?i=#{@omdb_id}&apikey=#{ENV['OMDB_KEY']}"
    result = JSON.parse(open(url).read)
    number_seasons = result['totalSeasons'].to_i
    # create a hash for subtitles
    @serie_subtitle = {}
    i = 1
    while i <= number_seasons do
      j = 1
      while j < 20
        # get subtitles based on language prefrence
        uri = URI.parse("https://rest.opensubtitles.org/search/episode-#{j}/imdbid-#{(@omdb_id)[2..-1]}/season-#{i}/sublanguageid-#{current_user.language == "EN" ? "eng" : "fre"}")
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
        j += 1
        # returns a unique id for subtitles to match them with episodes (e.g: 1|11 for season 1 episode 11)
        @serie_subtitle[parsed_response[0]["QueryParameters"]["season"].to_s + '|' + parsed_response[0]["QueryParameters"]["episode"].to_s] = sub_url
      end
        i += 1
    end
    i = 0
    while i < seriearray.count
      # returns a unique id for episodes to match them with subtitles (e.g: 1|11 for season 1 episode 11)
      current_episode = seriearray[i][0].to_s + '|' + seriearray[i][1].to_s
      @serie = Serie.new(
        season: seriearray[i][0],
        episode: seriearray[i][1],
        magnet: seriearray[i][2],
        title: seriearray[i][3],
        subtitle: @serie_subtitle[current_episode]
      )
      # associate logged in user to movie for personalised library
      @serie.movie_id = idmovie
      # save in DB
      if @serie.save
        i += 1
      else
        render :root
      end
    end
    redirect_to movie_path(@serie.movie_id)
  end
end
