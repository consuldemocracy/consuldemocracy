require "rails_helper"

describe Types::UserType do
  context "activity is not public" do
    let(:user) { create(:user, public_activity: false) }

    it "does not link debates" do
      create(:debate, author: user)

      response = run_graphql_field("User.public_debates", user)

      expect(response.items).to eq []
    end

    it "does not link proposals" do
      create(:proposal, author: user)

      response = run_graphql_field("User.public_proposals", user)

      expect(response.items).to eq []
    end

    it "does not link comments" do
      create(:comment, author: user)

      response = run_graphql_field("User.public_comments", user)

      expect(response.items).to eq []
    end
  end

  it "only links public comments" do
    user = create(:administrator).user
    create(:comment, author: user, body: "Public")
    create(:budget_investment_comment, author: user, valuation: true, body: "Valuation")

    response = execute("{ user(id: #{user.id}) { public_comments { edges { node { body } } } } }")
    received_comments = dig(response, "data.user.public_comments.edges")

    expect(received_comments).to eq [{ "node" => { "body" => "Public" }}]
  end
end
