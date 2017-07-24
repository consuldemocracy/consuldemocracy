require 'http'

API_ENDPOINT = 'https://decide.madrid.es/graphql'

def make_request(query_string)
  HTTP.headers('User-Agent' => 'Mozilla/5.0', accept: 'application/json')
      .get(
        API_ENDPOINT,
        params: { query: query_string.gsub("\n", '').gsub(" ", '') }
      )
end

query = """
  {
    proposal(id: 1) {
        id,
        title,
        public_created_at
    }
  }
"""

response = make_request(query)

puts "Response code: #{response.code}"
puts "Response body: #{response.body}"