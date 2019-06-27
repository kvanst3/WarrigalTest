class SeriesController < ApplicationController
  def create
    @my_test_variable = params[:my_test_variable]
    idmovie = Movie.where(movieid: @my_test_variable).ids.last

    seriearray = []
    # parse tracker response
    trackerTV = "https://tv-v2.api-fetch.website/show/" + @my_test_variable
    torrent_result = JSON.parse(open(trackerTV).read)
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

    url = "http://www.omdbapi.com/?i=#{@my_test_variable}&apikey=#{ENV['OMDB_KEY']}"
    result = JSON.parse(open(url).read)
    number_seasons = result['totalSeasons'].to_i
    # create a hash for subtitles
    @serie_subs = {}
    i = 1
    while i <= number_seasons do
      j = 1
      while j < 20
        # get subtitles based on language prefrence
        uri = URI.parse("https://rest.opensubtitles.org/search/episode-#{j}/imdbid-#{(@my_test_variable)[2..-1]}/season-#{i}/sublanguageid-#{current_user.language == "EN" ? "eng" : "fre"}")
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
    i = 0
    while i < seriearray.count
      current_episode = seriearray[i][0].to_s + seriearray[i][1].to_s
      @serie = Serie.new(
        season: seriearray[i][0],
        episode: seriearray[i][1],
        magnet: seriearray[i][2],
        title: seriearray[i][3],
        subtitle: @serie_subs[current_episode]
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
