require 'rails_helper'

describe ConsulSchema do
  let(:context) { {} }  # should be overriden for specific queries
  let(:variables) { {} }
  let(:result) { ConsulSchema.execute(query_string, context: context, variables: variables) }

  describe "answers simple queries" do
    let(:query_string) { "{ proposals { edges { node { title } } } }" }
    let(:context) {
      { proposal: create(:proposal, title: "A new proposal") }
    }

    it "can return proposal titles" do
      proposals = result["data"]["proposals"]["edges"].collect { |edge| edge['node'] }
      expect(proposals.size).to eq(1)
      expect(proposals.first['title']).to eq("A new proposal")
    end
  end

  describe "queries with nested associations" do
    let(:query_string) { "{ proposals { edges { node { id, title, author { username } } } } }" }

    let(:mrajoy) { create(:user, username: 'mrajoy') }
    let(:dtrump) { create(:user, username: 'dtrump') }
    let(:context) {
      { proposal_1: create(:proposal, id: 1, title: "Bajar el IVA", author: mrajoy) }
      { proposal_2: create(:proposal, id: 2, title: "Censurar los memes", author: mrajoy) }
      { proposal_3: create(:proposal, id: 3, title: "Construir un muro", author: dtrump) }
    }

    it "returns the appropiate fields" do
      proposals = result["data"]["proposals"]["edges"].collect { |edge| edge['node'] }

      expected_result = [
        {
          'id' => 1,
          'title' => 'Bajar el IVA',
          'author' => { 'username' => 'mrajoy' }
        },
        {
          'id' => 2,
          'title' => 'Censurar los memes',
          'author' => { 'username' => 'mrajoy' }
        },
        {
          'id' => 3,
          'title' => 'Construir un muro',
          'author' => { 'username' => 'dtrump' }
        }
      ]

      expect(proposals).to match_array(expected_result)
    end
  end
end
