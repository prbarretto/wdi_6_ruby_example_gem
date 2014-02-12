require 'spec_helper'
require "addressable/template"

describe GaExampleGem::Client do
	before do
    @client = GaExampleGem::Client.new
    @client.configure do |config|
      config.api_key = ""
    end
    @authenticated_client = GaExampleGem::Client.new
    @authenticated_client.configure do |config|
      config.api_key = "foobar"
    end
  end

  describe '#get_xkcd' do
  	before do
      # Intercept an HTTP request that looks like this,
      # and return a specific JSON file instead for the body
      stub_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?num=1').
        to_return(body: fixture('single_xkcd.json'))
    end

    it "fetchs a single xkcd webcomic" do
      # Make the request
      comic = @client.get_xkcd(1)

      # Expect that you made a request
      expect(a_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?num=1')).to have_been_made

      # Check the results of the JSON file/body of HTTP request that we intercepted
      expect(comic.first["title"]).to eq "Barrel - Part 1"
    end
  end

  describe '#get_xkcds_from_year for unauthenticated client' do
    before do
      # Intercept an HTTP request that looks like this,
      # and return a specific JSON file instead for the body
      stub_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?year=2006').
        to_return(body: fixture('year_xkcd.json'))
    end

     it "fetches a max of 3 comics for unauthenticated client" do
      # Make the request
      comics = @client.get_xkcds_from_year(2006)

      # Expect that you made a request
      expect(a_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?year=2006')).to have_been_made

      # Check the results of the JSON file/body of HTTP request that we intercepted
      expect(comics[0]["title"]).to eq "Barrel - Part 1"
      expect(comics[1]["title"]).to eq "Petit Trees (sketch)"
      expect(comics[2]["title"]).to eq "Island (sketch)"
      expect(comics.count).to eq 3
      expect(comics).to be_an Array
    end
  end

  describe '#get_xkcds_from_year for authenticated client' do
    before do
      # Intercept an HTTP request that looks like this,
      # and return a specific JSON file instead for the body
      stub_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?year=2006&api_key=foobar').
        to_return(body: fixture('whole_year_xkcd.json'))
    end

    it 'fetches all the comics for an authenticated client' do
    comics = @authenticated_client.get_xkcds_from_year(2006)

      expect(comics).to be_an Array
      expect(comics.count).to eq 203
    end
  end

  describe '#get_comics' do
    before do
      stub_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?month=3').
        to_return(body: fixture('unauth_month_3.json'))

      stub_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?day=1').
        to_return(body: fixture('unauth_day_1.json'))

      stub_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?year=2007&month=3').
        to_return(body: fixture('unauth_year_2007_month_3.json'))

      stub_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?year=2007&month=3&api_key=foobar').
        to_return(body: fixture('auth_year_2007_month_3.json'))
    end

    it 'returns 3 comics from a month' do
      comics = @client.get_comics(month: 3)

      expect(a_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?month=3')).to have_been_made

      expect(comics[2]["title"]).to eq "Classhole"
      expect(comics.count).to eq 3
      expect(comics).to be_an Array
    end

    it 'returns 3 comics for day' do
      comics = @client.get_comics(day: 1)

      expect(a_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?day=1')).to have_been_made

      expect(comics[2]["title"]).to eq "Island (sketch)"
      expect(comics.count).to eq 3
      expect(comics).to be_an Array
    end

    it 'returns 3 comics for a day and month' do
      comics = @client.get_comics(year: 2007, month: 3)

      expect(a_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?year=2007&month=3')).to have_been_made

      expect(comics[2]["title"]).to eq "Chess Enlightenment"
      expect(comics.count).to eq 3
      expect(comics).to be_an Array
    end

    it 'returns all comics for a day and month for auth user' do
      comics = @authenticated_client.get_comics(year: 2007, month: 3)

      expect(a_request(:get, 'http://xkcd-unofficial-api.herokuapp.com/xkcd?year=2007&month=3&api_key=foobar')).to have_been_made

      expect(comics[7]["title"]).to eq "Keyboards are Disgusting"
      expect(comics.count).to eq 13
      expect(comics).to be_an Array
    end
  end
end
