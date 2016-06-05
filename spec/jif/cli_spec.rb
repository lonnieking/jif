require 'spec_helper'

describe Jif::CLI do
  let(:query_terms)            { %w[facepalm] }
  let(:no_results_query_terms) { %w[a search that gives no results] }
  let(:search_response_body)   { File.read('spec/fixtures/giphy_response.json') }
  let(:random_response_body)   { File.read('spec/fixtures/giphy_random_response.json') }
  let(:empty_response_body)    { File.read('spec/fixtures/giphy_empty_response.json') }


  before do
    # This line suppreses all standard out calls. This isn't ideal, but it's the only way I've discovered
    # so far to suppress the annoying Thor warnings that appear as a result of the use of
    # expect_any_instance_of(Jif::CLI) in some of the tests below
    allow($stdout).to receive(:write)

    # This line suppresses the final Kernel#system call so that images don't display in the spec summary
    allow_any_instance_of(Jif::CLI).to receive(:system)
  end

  shared_examples_for "jif CLI command behaviour" do
    it 'writes the gif data to a temporary file' do
      temp_file = Tempfile.create('test_temp_file')
      expect(Tempfile).to receive(:create).and_return(temp_file)
    end

    it 'displays a gif with imgcat when results are given' do
      expect(Shellwords).to receive(:escape).and_call_original
      expect_any_instance_of(Jif::CLI).to receive(:system).with(include "#{Jif::CLI::IMGCAT_LOCATION}")
    end

    it 'displays a 404 gif when there are no search results' do
      stub_request(:any, /.*api.giphy.com.*/).to_return(:status => 200, :body => empty_response_body, :headers => {})

      expect_any_instance_of(Jif::CLI).to receive(:open).with(include "#{Jif::CLI::NO_RESULTS_GIF}").and_call_original
      expect(Shellwords).to receive(:escape).and_call_original
      expect_any_instance_of(Jif::CLI).to receive(:system).with(include "#{Jif::CLI::IMGCAT_LOCATION}")
    end
  end

  describe '#search' do
    include_examples "jif CLI command behaviour"

    before do
      # Stub gif download
      stub_request(:get, "http://media1.giphy.com/media/Y8iVchGvwtFh6/200.gif").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {})

      stub_request(:get, "http://api.giphy.com/v1/gifs/search?api_key=dc6zaTOxFJmzC&limit=1&q=eric%20mind%20blown").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(:status => 200, :body => search_response_body, :headers => {})

      stub_request(:get, "http://api.giphy.com/v1/gifs/search?api_key=dc6zaTOxFJmzC&limit=1&q=facepalm").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(:status => 200, :body => search_response_body, :headers => {})
    end

    after do
      subject.search
    end

    it 'finds the first image file in the results' do
      first_image_url = JSON.parse(search_response_body)['data'].first["images"]["fixed_height"]["url"]
      expect_any_instance_of(Jif::CLI).to receive(:open).with(first_image_url).and_call_original
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
      stub_request(:get, "http://api.giphy.com/v1/gifs/search?api_key=dc6zaTOxFJmzC&limit=1&q=double%20rainbow%20all%20the%20way").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(:status => 200, :body => search_response_body, :headers => {})

      query_terms = %w[double rainbow all the way]
      subject.search(query_terms)

      expected_query_terms = query_terms.join(' ')
      expect(WebMock).to have_requested(:get, Jif::CLI::GIPHY_API_URL + Jif::CLI::SEARCH_ENDPOINT)
      .with(query: {"q": "#{expected_query_terms}", "limit": "1", "api_key": Jif::CLI::PUBLIC_API_KEY})
    end
  end

  describe '#random' do
    include_examples 'jif CLI command behaviour'

    before do
      stub_request(:get, "http://media1.giphy.com/media/xT5LMS0YGpXRjSaKVa/giphy.gif").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {})

     stub_request(:get, "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC").
       with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
       to_return(:status => 200, :body => random_response_body, :headers => {})
    end

    after do
      subject.random
    end

    it 'finds the image location in the response body' do
      image_url = JSON.parse(random_response_body)['data']["image_url"]
      expect_any_instance_of(Jif::CLI).to receive(:open).with(image_url).and_call_original
    end

    it 'gets a gif from giphy using the random endpoint' do
      subject.random
      expect(WebMock).to have_requested(:get, Jif::CLI::GIPHY_API_URL + Jif::CLI::RANDOM_ENDPOINT)
        .with(query: {"api_key": Jif::CLI::PUBLIC_API_KEY})
    end
  end

  describe 'failure - imgcat script missing' do
    it 'raises an error if it cannot find the imgcat script' do
      stub_request(:get, "http://api.giphy.com/v1/gifs/search?api_key=dc6zaTOxFJmzC&limit=1&q=eric%20mind%20blown").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(:status => 200, :body => search_response_body, :headers => {})

      stub_const("Jif::CLI::IMGCAT_LOCATION", 'invalid/imgcat/script/path')
      expect{ subject.search }.to raise_error Jif::CLI::ScriptNotFoundError
    end
  end
end
