require 'rails_helper'

describe ConsulSchema do
  let(:context) { {} }  # should be overriden for specific queries
  let(:variables) { {} }
  let(:result) { ConsulSchema.execute(query_string, context: context, variables: variables) }

  describe "queries to single elements" do
    let(:proposal) { create(:proposal, title: 'Proposal Title') }

    describe "can returns fields of" do
      let(:query_string) { "{ proposal(id: #{proposal.id}) { id, title } }" }
      subject(:returned_proposal) { result['data']['proposal'] }

      it "numeric type" do
        expect(returned_proposal['id']).to eq(proposal.id)
      end

      it "String type" do
        expect(returned_proposal['title']).to eq(proposal.title)
      end
    end

    describe "support nested" do
      let(:proposal_author) { create(:user) }
      let(:comments_author) { create(:user) }
      let(:proposal) { create(:proposal, author: proposal_author) }
      let!(:comment_1) { create(:comment, author: comments_author, commentable: proposal) }
      let!(:comment_2) { create(:comment, author: comments_author, commentable: proposal) }
      let(:query_string) { "{ proposal(id: #{proposal.id}) { author { username }, comments { edges { node { body } } } } }" }
      subject(:returned_proposal) { result['data']['proposal'] }

      it ":has_one associations" do
        skip "I think this test isn't needed"
        # TODO: the only has_one associations inside the project are in the User
        # model (administrator, valuator, etc.). But since I think this data
        # shouldn't be exposed to the API, there's no point in testing this.
      end

      it ":belongs_to associations" do
        expect(returned_proposal['author']['username']).to eq(proposal_author.username)
      end

      it ":has_many associations" do
        comments = returned_proposal['comments']['edges'].collect { |edge| edge['node'] }
        comment_bodies = comments.collect { |comment| comment['body'] }

        expect(comment_bodies).to match_array([comment_1.body, comment_2.body])
      end
    end

    describe "do not expose confidential" do
      let(:user) { create(:user) }
      subject(:data) { result['data'] }
      subject(:errors) { result['errors'] }
      subject(:error_msg) { errors.first['message'] }

      describe "fields of Int type" do
        let(:query_string) { "{ user(id: #{user.id}) { failed_census_calls_count } }" }

        specify { expect(data).to be_nil }
        specify { expect(error_msg).to eq("Field 'failed_census_calls_count' doesn't exist on type 'User'") }
      end

      describe "fields of String type" do
        let(:query_string) { "{ user(id: #{user.id}) { encrypted_password } }" }

        specify { expect(data).to be_nil }
        specify { expect(error_msg).to eq("Field 'encrypted_password' doesn't exist on type 'User'") }
      end

      describe "fields inside nested queries" do
        let(:proposal) { create(:proposal, author: user) }
        let(:query_string) { "{ proposal(id: #{proposal.id}) { author { reset_password_sent_at } } }" }

        specify { expect(data).to be_nil }
        specify { expect(error_msg).to eq("Field 'reset_password_sent_at' doesn't exist on type 'User'") }
      end

      describe ":has_one associations" do
        let(:administrator) { create(:administrator) }
        let(:query_string) { "{ user(id: #{user.id}) { administrator { id } } }" }

        specify { expect(data).to be_nil }
        specify { expect(error_msg).to eq("Field 'administrator' doesn't exist on type 'User'") }
      end

      describe ":belongs_to associations" do
        let(:query_string) { "{ user(id: #{user.id}) { failed_census_calls { id } } }" }
        let(:census_call) { create(:failed_census_call, user: user) }

        specify { expect(data).to be_nil }
        specify { expect(error_msg).to eq("Field 'failed_census_calls' doesn't exist on type 'User'") }
      end

      describe ":has_many associations" do
        let(:message) { create(:direct_message, sender: user) }
        let(:query_string) { "{ user(id: #{user.id}) { direct_messages_sent { id } } }" }

        specify { expect(data).to be_nil }
        specify { expect(error_msg).to eq("Field 'direct_messages_sent' doesn't exist on type 'User'") }
      end
    end
  end

  describe "queries to collections" do
    let(:query_string) { "{ proposals { edges { node { id, title, author { username } } } } }" }

    let(:mrajoy) { create(:user, username: 'mrajoy') }
    let(:dtrump) { create(:user, username: 'dtrump') }
    let(:context) do
      { proposal_1: create(:proposal, id: 1, title: "Bajar el IVA", author: mrajoy) }
      { proposal_2: create(:proposal, id: 2, title: "Censurar los memes", author: mrajoy) }
      { proposal_3: create(:proposal, id: 3, title: "Construir un muro", author: dtrump) }
    end

    it "return the appropiate fields" do
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
