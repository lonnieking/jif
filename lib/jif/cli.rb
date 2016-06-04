module Jif
  class CLI < Thor
    class ScriptNotFoundError < StandardError; end

    desc "search SEARCH TERMS", "Displays a gif related to SEARCH TERMS"
    def search(*query_terms)
      search_results = giphy_search(query_terms)
      gif_url = search_results.first["images"]["fixed_height"]["url"]
      display_gif_from gif_url if imgcat_available?
    end

    private

    no_commands {
      GIPHY_API_URL   = 'http://api.giphy.com'
      SEARCH_ENDPOINT = '/v1/gifs/search?'
      PUBLIC_API_KEY  = 'dc6zaTOxFJmzC'
      DEFAULT_QUERY   = %w[eric mind blown]
      IMGCAT_LOCATION = "#{Dir.pwd}/scripts/imgcat"

      def giphy_search(query_terms)
        query = query_terms.any? ? query_terms.join('+') : DEFAULT_QUERY.join('+')
        gif_request = SEARCH_ENDPOINT + "q=#{query}&limit=1&api_key=" + PUBLIC_API_KEY
        response = http_client.get(gif_request)
        JSON.parse(response.body)['data']
      end

      def http_client
        @client ||= Faraday.new(url: GIPHY_API_URL) do |faraday|
          faraday.request  :url_encoded
          faraday.adapter  Faraday.default_adapter
        end
      end

      def display_gif_from(gif_url)
        Tempfile.create('tmp') do |file|
          file << open(gif_url).read
          bash "#{IMGCAT_LOCATION} #{file.path}"
        end
      end

      def bash(command)
        system "bash -c #{Shellwords.escape command}"
      end

      def imgcat_available?
        return true if File.exists? IMGCAT_LOCATION
        raise ScriptNotFoundError
      end
    }
  end
end
