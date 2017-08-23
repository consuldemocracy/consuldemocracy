require 'http'

API_ENDPOINT = 'https://decide.madrid.es/graphql'.freeze

def make_request(query_string)
  HTTP.headers('User-Agent' => 'Mozilla/5.0', accept: 'application/json')
      .get(
        API_ENDPOINT,
        params: { query: query_string.delete("\n").delete(" ") }
      )
end

def build_query(options = {})
  page_size = options[:page_size] || 25
  page_size_parameter = "first: #{page_size}"

  page_number = options[:page_number] || 0
  after_parameter = page_number.positive? ? ", after: \"#{options[:next_cursor]}\"" : ""

  <<-GRAPHQL
  {
    proposals(#{page_size_parameter}#{after_parameter}) {
      pageInfo {
        endCursor,
        hasNextPage
      },
      edges {
        node {
          id,
          title,
          public_created_at
        }
      }
    }
  }
  GRAPHQL
end

page_number = 0
next_cursor = nil
proposals   = []

loop do

  puts "> Requesting page #{page_number}"

  query = build_query(page_size: 25, page_number: page_number, next_cursor: next_cursor)
  response = make_request(query)

  response_hash  = JSON.parse(response.body)
  page_info      = response_hash['data']['proposals']['pageInfo']
  has_next_page  = page_info['hasNextPage']
  next_cursor    = page_info['endCursor']
  proposal_edges = response_hash['data']['proposals']['edges']

  puts "\tHTTP code: #{response.code}"

  proposal_edges.each do |edge|
    proposals << edge['node']
  end

  page_number += 1

  break unless has_next_page
end
