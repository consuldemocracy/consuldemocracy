require 'rails_helper'

describe ConsulSchema do
  let(:context) { {} }  # should be overriden for specific queries
  let(:variables) { {} }
  let(:result) { ConsulSchema.execute(query_string, context: context, variables: variables) }

  describe "queries to single elements" do
    let(:proposal) { create(:proposal, title: 'Proposal Title') }
    let(:query_string) { "{ proposal(id: #{proposal.id}) { id, title } }" }

    it "returns fields of numeric type" do
      returned_proposal = result['data']['proposal']
      expect(returned_proposal['id']).to eq(proposal.id)
    end

    it "returns fields of String type" do
      returned_proposal = result['data']['proposal']
      expect(returned_proposal['title']).to eq('Proposal Title')
    end

    describe "supports nested queries" do
      it "with :has_one associations" do
        skip "I think this test isn't needed"
        # TODO: the only has_one associations inside the project are in the User
        # model (administrator, valuator, etc.). But since I think this data
        # shouldn't be exposed to the API, there's no point in testing this.
        #
        # user = create(:user)
        # admin = create(:administrator)
        # user.administrator = admin
        # query_string = "{ user(id: #{user.id}) { administrator { id } } }"
        #
        # result = ConsulSchema.execute(query_string, context: {}, variables: {})
        # returned_admin = result['data']['user']['administrator']
        #
        # expect(returned_admin.id).to eq(admin.id)
      end

      it "with :belongs_to associations" do
        user = create(:user)
        proposal = create(:proposal, author: user)
        query_string = "{ proposal(id: #{proposal.id}) { author { username } } }"

        result = ConsulSchema.execute(query_string, context: {}, variables: {})
        returned_proposal = result['data']['proposal']

        expect(returned_proposal['author']['username']).to eq(user.username)
      end

      it "with :has_many associations" do
        user = create(:user)
        proposal = create(:proposal)
        create(:comment, body: "Blah Blah", author: user, commentable: proposal)
        create(:comment, body: "I told ya", author: user, commentable: proposal)
        query_string = "{ proposal(id: #{proposal.id}) { comments { edges { node { body } } } } }"

        result = ConsulSchema.execute(query_string, context: {}, variables: {})
        comments = result['data']['proposal']['comments']['edges'].collect { |edge| edge['node'] }
        comment_bodies = comments.collect { |comment| comment['body'] }

        expect(comment_bodies).to match_array(["Blah Blah", "I told ya"])
      end
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
