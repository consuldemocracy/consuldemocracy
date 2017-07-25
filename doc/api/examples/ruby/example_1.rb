require 'http'

API_ENDPOINT = 'https://decide.madrid.es/graphql'.freeze

def make_request(query_string)
  HTTP.headers('User-Agent' => 'Mozilla/5.0', accept: 'application/json')
      .get(
        API_ENDPOINT,
        params: { query: query_string.delete("\n").delete(" ") }
      )
end

query = <<-GRAPHQL
  {
    proposal(id: 1) {
        id,
        title,
        public_created_at
    }
  }
GRAPHQL

response = make_request(query)

puts "Response code: #{response.code}"
puts "Response body: #{response.body}"
