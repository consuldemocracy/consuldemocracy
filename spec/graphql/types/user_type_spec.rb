require "rails_helper"

describe Types::UserType do
  context "activity is not public" do
    let(:user) { create(:user, public_activity: false) }

    it "does not link debates" do
      create(:debate, author: user)

      response = execute("{ user(id: #{user.id}) { public_debates { edges { node { title } } } } }")
      received_debates = dig(response, "data.user.public_debates.edges")

      expect(received_debates).to eq []
    end

    it "does not link proposals" do
      create(:proposal, author: user)

      response = execute("{ user(id: #{user.id}) { public_proposals { edges { node { title } } } } }")
      received_proposals = dig(response, "data.user.public_proposals.edges")

      expect(received_proposals).to eq []
    end

    it "does not link comments" do
      create(:comment, author: user)

      response = execute("{ user(id: #{user.id}) { public_comments { edges { node { body } } } } }")
      received_comments = dig(response, "data.user.public_comments.edges")

      expect(received_comments).to eq []
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
