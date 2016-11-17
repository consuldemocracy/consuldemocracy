require 'rails_helper'

describe GraphqlController do
  let!(:uri) { URI::HTTP.build(host: 'localhost', path: '/queries', port: 3000) }

  describe "GET request" do
    it "is accepted when valid" do
      # Like POST requests but the query string goes in the URL
      # More info at: http://graphql.org/learn/serving-over-http/#get-request
      skip
    end

    it "is rejected when not valid" do
      skip
    end
  end

  describe "POST request" do
    let(:post_request) {
      req = Net::HTTP::Post.new(uri)
      req['Content-Type'] = 'application/json'
      req
    }

    it "succeeds when valid" do
      body = { query: "{ proposals(first: 2) { edges { node { id } } } }" }.to_json
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        post_request.body = body
        http.request(post_request)
      end

      # Is it enough to check the status code or should I also check the body?
      expect(response.code.to_i).to eq(200)
    end

    it "succeeds and returns an error when disclosed attributes are requested" do
      body = { query: "{ user(id: 1) { encrypted_password } }" }.to_json
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        post_request.body = body
        http.request(post_request)
      end

      body_hash = JSON.parse(response.body)
      expect(body_hash['errors']).to be_present
    end

    it "fails when no query string is provided" do
      body = {}.to_json
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        post_request.body = body
        http.request(post_request)
      end

      # TODO: I must find a way to handle this better. Right now it shows a 500
      # Internal Server Error, I think I should always return a valid (but empty)
      # JSON document like '{}'
      expect(response.code.to_i).not_to eq(200)
    end

  end

end
