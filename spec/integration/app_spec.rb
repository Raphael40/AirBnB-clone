require "spec_helper"
require "rack/test"
require_relative '../../app'
require 'json'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  # Write your integration tests below.
  # If you want to split your integration tests
  # accross multiple RSpec files (for example, have
  # one test suite for each set of related features),
  # you can duplicate this test file to create a new one.


  context 'GET /' do
    it 'should get the homepage' do
      response = get('/')

      expect(response.status).to eq(200)
    end
  end

  context 'GET /listings' do
    it 'should return the list of the listings' do
      response = get('/listings')

      expect(response.status).to eq(200)
      expect(response.body).to include('listing_1')
      expect(response.body).to include('listing_2')
    end
  end

  context 'GET /listings/new' do
    it 'should return a form to add a new listing' do
      response = get('/listings/new')

      expect(response.status).to eq(200)
      expect(response.body).to include('Add a new listing')
      expect(response.body).to include('<form method="POST" action="/listings/new">')
    end
  end
end
