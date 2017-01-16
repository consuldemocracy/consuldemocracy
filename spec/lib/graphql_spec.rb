require 'rails_helper'

# ------------------------------------------------------------------------------
api_types_creator = GraphQL::ApiTypesCreator.new(API_TYPE_DEFINITIONS)
created_api_types = api_types_creator.create

query_type_creator = GraphQL::QueryTypeCreator.new(created_api_types)
QueryType = query_type_creator.create

ConsulSchema = GraphQL::Schema.define do
  query QueryType
  max_depth 12
end
# ------------------------------------------------------------------------------

def execute(query_string, context = {}, variables = {})
  ConsulSchema.execute(query_string, context: context, variables: variables)
end

def dig(response, path)
  response.dig(*path.split('.'))
end

def hidden_field?(response, field_name)
  data_is_empty = response['data'].nil?
  error_is_present = ((response['errors'].first['message'] =~ /Field '#{field_name}' doesn't exist on type '[[:alnum:]]*'/) == 0)
  data_is_empty && error_is_present
end

describe 'ConsulSchema' do
  let(:user) { create(:user) }
  let(:proposal) { create(:proposal, author: user) }

  it "returns fields of Int type" do
    response = execute("{ proposal(id: #{proposal.id}) { id } }")
    expect(dig(response, 'data.proposal.id')).to eq(proposal.id)
  end

  it "returns fields of String type" do
    response = execute("{ proposal(id: #{proposal.id}) { title } }")
    expect(dig(response, 'data.proposal.title')).to eq(proposal.title)
  end

  it "returns has_one associations" do
    skip "Organizations are not being exposed yet"
    organization = create(:organization)
    response = execute("{ user(id: #{organization.user_id}) { organization { name } } }")
    expect(dig(response, 'data.user.organization.name')).to eq(organization.name)
  end

  it "returns belongs_to associations" do
    response = execute("{ proposal(id: #{proposal.id}) { public_author { username } } }")
    expect(dig(response, 'data.proposal.public_author.username')).to eq(proposal.public_author.username)
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

  it "executes deeply nested queries" do
    skip "Organizations are not being exposed yet"
    org_user = create(:user)
    organization = create(:organization, user: org_user)
    org_proposal = create(:proposal, author: org_user)
    response = execute("{ proposal(id: #{org_proposal.id}) { public_author { organization { name } } } }")

    expect(dig(response, 'data.proposal.public_author.organization.name')).to eq(organization.name)
  end

  it "hides confidential fields of Int type" do
    response = execute("{ user(id: #{user.id}) { failed_census_calls_count } }")
    expect(hidden_field?(response, 'failed_census_calls_count')).to be_truthy
  end

  it "hides confidential fields of String type" do
    response = execute("{ user(id: #{user.id}) { encrypted_password } }")
    expect(hidden_field?(response, 'encrypted_password')).to be_truthy
  end

  it "hides confidential has_one associations" do
    user.administrator = create(:administrator)
    response = execute("{ user(id: #{user.id}) { administrator { id } } }")
    expect(hidden_field?(response, 'administrator')).to be_truthy
  end

  it "hides confidential belongs_to associations" do
    create(:failed_census_call, user: user)
    response = execute("{ user(id: #{user.id}) { failed_census_calls { id } } }")
    expect(hidden_field?(response, 'failed_census_calls')).to be_truthy
  end

  it "hides confidential has_many associations" do
    create(:direct_message, sender: user)
    response = execute("{ user(id: #{user.id}) { direct_messages_sent { id } } }")
    expect(hidden_field?(response, 'direct_messages_sent')).to be_truthy
  end

  it "hides confidential fields inside deeply nested queries" do
    response = execute("{ proposals(first: 1) { edges { node { public_author { encrypted_password } } } } }")
    expect(hidden_field?(response, 'encrypted_password')).to be_truthy
  end
end
