require 'spec_helper'

describe Jif::CLI do
  describe '#search' do
    let(:query_terms)     { %w[facepalm] }
    let(:response_body)   { File.read('spec/fixtures/giphy_response.json') }

    before do
      # Stub the gif search request
      stub_request(:get, "http://api.giphy.com/v1/gifs/search?api_key=dc6zaTOxFJmzC&limit=1&q=facepalm").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(:status => 200, :body => response_body, :headers => {})

      # Stub the gif request
      stub_request(:get, "http://media1.giphy.com/media/Y8iVchGvwtFh6/200.gif").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})

      # Stub the no-query-terms-provided gif search request
      default_query_terms = Jif::CLI::DEFAULT_QUERY.join('%20')
      stub_request(:get, "http://api.giphy.com/v1/gifs/search?api_key=dc6zaTOxFJmzC&limit=1&q=#{default_query_terms}").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(:status => 200, :body => response_body, :headers => {})

      # Stub the multiple-query-terms-proved gif search request
      stub_request(:get, "http://api.giphy.com/v1/gifs/search?api_key=dc6zaTOxFJmzC&limit=1&q=double%20rainbow%20all%20the%20way").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(:status => 200, :body => response_body, :headers => {})

      # This line suppreses all standard out calls. This isn't ideal, but it's the only way I've discovered
      # so far to suppress the annoying Thor warnings that appear as a result of the use of
      # expect_any_instance_of(Jif::CLI) in some of the tests below
      allow($stdout).to receive(:write)

      # This line suppresses the final Kernel#system call so that images don't display in the spec summary
      allow_any_instance_of(Jif::CLI).to receive(:system)
    end

    it 'searches giphy for gifs based on provided query terms' do
      subject.search(query_terms)

      expect(WebMock).to have_requested(:get, Jif::CLI::GIPHY_API_URL + Jif::CLI::SEARCH_ENDPOINT)
      .with(query: {"q": "facepalm", "limit": "1", "api_key": Jif::CLI::PUBLIC_API_KEY})
    end

    it 'based on default query terms when none are provided' do
      default_query_terms = Jif::CLI::DEFAULT_QUERY.join(' ')
      subject.search

      expect(WebMock).to have_requested(:get, Jif::CLI::GIPHY_API_URL + Jif::CLI::SEARCH_ENDPOINT)
      .with(query: {"q": "#{default_query_terms}", "limit": "1", "api_key": Jif::CLI::PUBLIC_API_KEY})
    end

    it 'joins multiple query terms' do
      query_terms = %w[double rainbow all the way]
      subject.search(query_terms)

      expected_query_terms = query_terms.join(' ')
      expect(WebMock).to have_requested(:get, Jif::CLI::GIPHY_API_URL + Jif::CLI::SEARCH_ENDPOINT)
      .with(query: {"q": "#{expected_query_terms}", "limit": "1", "api_key": Jif::CLI::PUBLIC_API_KEY})
    end

    it 'finds the first image file in the results' do
      first_image_url = JSON.parse(response_body)['data'].first["images"]["fixed_height"]["url"]
      expect_any_instance_of(Jif::CLI).to receive(:open).with(first_image_url).and_call_original
      subject.search(query_terms)
    end

    it 'writes the gif data to a temporary file' do
      temp_file = Tempfile.create('test_temp_file')
      expect(Tempfile).to receive(:create).and_return(temp_file)
      subject.search(query_terms)
    end

    it 'displays the gif with imgcat' do
      expect(Shellwords).to receive(:escape).and_call_original
      expect_any_instance_of(Jif::CLI).to receive(:system).with(include "#{Jif::CLI::IMGCAT_LOCATION}")
      subject.search(query_terms)
    end

    it 'raises an error if it cannot find the imgcat script' do
      stub_const("Jif::CLI::IMGCAT_LOCATION", 'invalid/imgcat/script/path')
      expect{ subject.search(query_terms) }.to raise_error Jif::CLI::ScriptNotFoundError
    end
  end
end
