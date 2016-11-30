require 'rails_helper'

# Hacerlo como los test de controlador de rails

describe GraphqlController, type: :request do
  let(:proposal) { create(:proposal) }

  it "answers simple json queries" do
    headers = { "CONTENT_TYPE" => "application/json" }
    #post "/widgets", '{ "widget": { "name":"My Widget" } }', headers
    post '/graphql', { query: "{ proposal(id: #{proposal.id}) { title } }" }.to_json, headers
    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)['data']['proposal']['title']).to eq(proposal.title)
  end

  
end

=begin
describe GraphqlController do
  let(:uri) { URI::HTTP.build(host: 'localhost', path: '/graphql', port: 3000) }
  let(:query_string) { "" }
  let(:body) { {query: query_string}.to_json }

  describe "POST requests" do
    let(:author) { create(:user) }
    let(:proposal) { create(:proposal, author: author) }
    let(:response) { HTTP.headers('Content-Type' => 'application/json').post(uri, body: body) }
    let(:response_body) { JSON.parse(response.body) }

    context "when query string is valid" do
      let(:query_string) { "{ proposal(id: #{proposal.id}) { title, author { username } } }" }
      let(:returned_proposal) { response_body['data']['proposal'] }

      it "returns HTTP 200 OK" do
        expect(response.code).to eq(200)
      end

      it "returns first-level fields" do
        expect(returned_proposal['title']).to eq(proposal.title)
      end

      it "returns nested fields" do
        expect(returned_proposal['author']['username']).to eq(author.username)
      end
    end

    context "when query string asks for invalid fields" do
      let(:query_string) { "{ proposal(id: #{proposal.id}) { missing_field } }" }

      it "returns HTTP 200 OK" do
        expect(response.code).to eq(200)
      end

      it "doesn't return any data" do
        expect(response_body['data']).to be_nil
      end

      it "returns error inside body" do
        expect(response_body['errors']).to be_present
      end
    end

    context "when query string is not valid" do
      let(:query_string) { "invalid" }

      it "returns HTTP 400 Bad Request" do
        expect(response.code).to eq(400)
      end
    end

    context "when query string is missing" do
      let(:query_string) { nil }

      it "returns HTTP 400 Bad Request" do
        expect(response.code).to eq(400)
      end
    end

    context "when body is missing" do
      let(:body) { nil }

      it "returns HTTP 400 Bad Request" do
        expect(response.code).to eq(400)
      end
    end

  end
end
=end
