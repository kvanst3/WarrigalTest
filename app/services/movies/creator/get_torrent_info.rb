# ::Movies::Creator::GetTorrentInfo.new(torrent_id).call

module Movies
  module Creator
    class GetTorrentInfo

      def initialize(torrent_id)
        @torrent_id = torrent_id
      end

      def call
        valid_torrent? ? valid_torrent_response : invalid_torrent_response
      end

      private

      attr_reader :torrent_id

      def torrent_url
        @torrent_url ||= "https://tv-v2.api-fetch.website/movie/" + torrent_id
      end

      def open_torrent_url
        @open_torrent_url ||= open(torrent_url).read
      end

      def valid_torrent?
        !!JSON.parse(open_torrent_url)
      rescue JSON::ParserError
        false
      end

      def valid_torrent_response
        response = JSON.parse(open_torrent_url)
        response["torrents"].first[1].first[1]
      end

      def invalid_torrent_response
        { "provider"=>"n/a", "filesize"=>"n/a", "size"=>0, "peer"=>0, "seed"=>0, "url"=>"#" }
      end

    end
  end
end
