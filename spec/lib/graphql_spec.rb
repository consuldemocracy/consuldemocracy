require 'rails_helper'

# TODO: uno por cada tipo escalar, uno por cada asociacion, uno con query anidada * 2 (uno para asegurarse de que se muestra y otro para cuando se oculta)
def execute(query_string, context = {}, variables = {})
  ConsulSchema.execute(query_string, context: context, variables: variables)
end

def dig(response, path)
  response.dig(*path.split('.'))
end

describe ConsulSchema do
  let(:proposal_author) { create(:user) }
  let(:proposal) { create(:proposal, author: proposal_author) }

  it "returns fields of Int type" do
    response = execute("{ proposal(id: #{proposal.id}) { id } }")
    expect(dig(response, 'data.proposal.id')).to eq(proposal.id)
  end

  it "returns fields of String type" do
    response = execute("{ proposal(id: #{proposal.id}) { title } }")
    expect(dig(response, 'data.proposal.title')).to eq(proposal.title)
  end

  it "returns has_one associations" do
    organization = create(:organization)
    response = execute("{ user(id: #{organization.user_id}) { organization { name } } }")
    expect(dig(response, 'data.user.organization.name')).to eq(organization.name)
  end

  it "returns belongs_to associations" do
    response = execute("{ proposal(id: #{proposal.id}) { author { username } } }")
    expect(dig(response, 'data.proposal.author.username')).to eq(proposal.author.username)
  end

  it "returns has_many associations" do
    comments_author = create(:user)
    comment_1 = create(:comment, author: comments_author, commentable: proposal)
    comment_2 = create(:comment, author: comments_author, commentable: proposal)

    response = execute("{ proposal(id: #{proposal.id}) { comments { edges { node { body } } } } }")
    comments = dig(response, 'data.proposal.comments.edges').collect { |edge| edge['node'] }
    comment_bodies = comments.collect { |comment| comment['body'] }

    expect(comment_bodies).to match_array([comment_1.body, comment_2.body])
  end

  # it "hides confidential fields of Int type" do
  #   response = execute("{ user(id: #{user.id}) { failed_census_calls_count } }")
  #   expect(response['data']).to be_nil
  #   expect(response[])
  # end
  #
  # it "hides confidential fields of String type" do
  #   skip
  #   response = execute("{ user(id: #{user.id}) { encrypted_password } }")
  # end
  #
  # it "hides confidential has_one associations" do
  #   skip
  #   response = execute("{ user(id: #{user.id}) { administrator { id } } }")
  # end
  #
  # it "hides confidential belongs_to associations" do
  #   skip
  #   response = execute("{ user(id: #{user.id}) { failed_census_calls { id } } }")
  # end
  #
  # it "hides confidential has_many associations" do
  #   skip
  #   response = execute("{ user(id: #{user.id}) { direct_messages_sent { id } } }")
  # end
  #
  #   describe "do not expose confidential" do
  #     let(:user) { create(:user) }
  #     subject(:data) { response['data'] }
  #     subject(:errors) { response['errors'] }
  #     subject(:error_msg) { errors.first['message'] }
  #
  #     describe "fields of Int type" do
  #       let(:query_string) { "{ user(id: #{user.id}) { failed_census_calls_count } }" }
  #
  #       specify { expect(data).to be_nil }
  #       specify { expect(error_msg).to eq("Field 'failed_census_calls_count' doesn't exist on type 'User'") }
  #     end
  #
  #     describe "fields of String type" do
  #       let(:query_string) { "{ user(id: #{user.id}) { encrypted_password } }" }
  #
  #       specify { expect(data).to be_nil }
  #       specify { expect(error_msg).to eq("Field 'encrypted_password' doesn't exist on type 'User'") }
  #     end
  #
  #     describe "fields inside nested queries" do
  #       let(:proposal) { create(:proposal, author: user) }
  #       let(:query_string) { "{ proposal(id: #{proposal.id}) { author { reset_password_sent_at } } }" }
  #
  #       specify { expect(data).to be_nil }
  #       specify { expect(error_msg).to eq("Field 'reset_password_sent_at' doesn't exist on type 'User'") }
  #     end
  #
  #     describe ":has_one associations" do
  #       let(:administrator) { create(:administrator) }
  #       let(:query_string) { "{ user(id: #{user.id}) { administrator { id } } }" }
  #
  #       specify { expect(data).to be_nil }
  #       specify { expect(error_msg).to eq("Field 'administrator' doesn't exist on type 'User'") }
  #     end
  #
  #     describe ":belongs_to associations" do
  #       let(:query_string) { "{ user(id: #{user.id}) { failed_census_calls { id } } }" }
  #       let(:census_call) { create(:failed_census_call, user: user) }
  #
  #       specify { expect(data).to be_nil }
  #       specify { expect(error_msg).to eq("Field 'failed_census_calls' doesn't exist on type 'User'") }
  #     end
  #
  #     describe ":has_many associations" do
  #       let(:message) { create(:direct_message, sender: user) }
  #       let(:query_string) { "{ user(id: #{user.id}) { direct_messages_sent { id } } }" }
  #
  #       specify { expect(data).to be_nil }
  #       specify { expect(error_msg).to eq("Field 'direct_messages_sent' doesn't exist on type 'User'") }
  #     end
  #   end
  #
  # describe "queries to collections" do
  #   let(:mrajoy) { create(:user, username: 'mrajoy') }
  #   let(:dtrump) { create(:user, username: 'dtrump') }
  #   let!(:proposal_1) { create(:proposal, id: 1, title: "Bajar el IVA", author: mrajoy) }
  #   let!(:proposal_2) { create(:proposal, id: 2, title: "Censurar los memes", author: mrajoy) }
  #   let!(:proposal_3) { create(:proposal, id: 3, title: "Construir un muro", author: dtrump) }
  #   subject(:returned_proposals) { response['data']['proposals']["edges"].collect { |edge| edge['node'] } }
  #
  #   describe "return fields of Int type" do
  #     let(:query_string) { "{ proposals { edges { node { id } } } }" }
  #     let(:ids) { returned_proposals.collect { |proposal| proposal['id'] } }
  #
  #     specify { expect(ids).to match_array([3, 1, 2]) }
  #   end
  #
  #   describe "return fields of String type" do
  #     let(:query_string) { "{ proposals { edges { node { title } } } }" }
  #     let(:titles) { returned_proposals.collect { |proposal| proposal['title'] } }
  #
  #     specify { expect(titles).to match_array(['Construir un muro', 'Censurar los memes', 'Bajar el IVA']) }
  #   end
  #
  #   describe "return nested fields" do
  #     let(:query_string) { "{ proposals { edges { node { author { username } } } } }" }
  #     let(:authors) { returned_proposals.collect { |proposal| proposal['author']['username'] } }
  #
  #     specify { expect(authors).to match_array(['mrajoy', 'dtrump', 'mrajoy']) }
  #   end
  # end
end
