module Jif
  class CLI < Thor
    class ScriptNotFoundError < StandardError; end

    desc "search SEARCH TERMS", "Displays a gif related to SEARCH TERMS"
    def search(*query_terms)
      search_results = giphy_search(query_terms)
      gif_location = search_results.any? ? search_results.first["images"]["fixed_height"]["url"] : NO_RESULTS_GIF
      display_gif_from gif_location if imgcat_available?
    end

    desc "random", "Displays a gif at random. Not guaranteed to be SFW."
    def random
      search_results = giphy_random
      gif_location = search_results.any? ? search_results["image_url"] : NO_RESULTS_GIF
      display_gif_from gif_location if imgcat_available?
    end

    private

    no_commands {
      GIPHY_API_URL   = 'http://api.giphy.com'
      SEARCH_ENDPOINT = '/v1/gifs/search'
      RANDOM_ENDPOINT = '/v1/gifs/random'
      PUBLIC_API_KEY  = 'dc6zaTOxFJmzC'
      DEFAULT_QUERY   = %w[eric mind blown]
      IMGCAT_LOCATION = File.expand_path("../../../scripts/imgcat", __FILE__)
      NO_RESULTS_GIF  = File.expand_path("../../../assets/none_found.gif", __FILE__)


      def giphy_search(query_terms)
        query = query_terms.any? ? query_terms.join('+') : DEFAULT_QUERY.join('+')
        gif_request = SEARCH_ENDPOINT + "?q=#{query}&limit=1&api_key=" + PUBLIC_API_KEY
        response = http_client.get(gif_request)
        JSON.parse(response.body)['data']
      end

      def giphy_random
        gif_request = RANDOM_ENDPOINT + "?api_key=" + PUBLIC_API_KEY
        response = http_client.get(gif_request)
        JSON.parse(response.body)['data']
      end

      def http_client
        @client ||= Faraday.new(url: GIPHY_API_URL) do |faraday|
          faraday.request  :url_encoded
          faraday.adapter  Faraday.default_adapter
        end
      end

      def display_gif_from(gif_location)
        Tempfile.create('tmp') do |file|
          file << open(gif_location).read
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
