require "rails_helper"

describe Types::ProposalType do
  it "does not link author if public activity is set to false" do
    create(:user, :with_proposal, username: "public",  public_activity: true)
    create(:user, :with_proposal, username: "private", public_activity: false)

    response = execute("{ proposals { edges { node { public_author { username } } } } }")
    received_authors = extract_fields(response, "proposals", "public_author.username")

    expect(received_authors).to match_array ["public"]
  end

  it "only returns date and hour for created_at" do
    created_at = Time.zone.parse("2017-12-31 9:30:15")
    create(:proposal, created_at: created_at)

    response = execute("{ proposals { edges { node { public_created_at } } } }")
    received_timestamps = extract_fields(response, "proposals", "public_created_at")

    expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
  end

  it "only returns tags with kind nil or category" do
    create(:tag, name: "Parks")
    create(:tag, :category, name: "Health")
    create(:tag, name: "Admin tag", kind: "admin")

    proposal = create(:proposal, tag_list: "Parks, Health, Admin tag")

    response = execute("{ proposal(id: #{proposal.id}) { tags  { edges { node { name } } } } }")
    received_tags = dig(response, "data.proposal.tags.edges").map { |node| node["node"]["name"] }

    expect(received_tags).to match_array ["Parks", "Health"]
  end

  it "returns nested votes for a proposal" do
    proposal = create(:proposal, voters: [create(:user), create(:user)])

    response = execute("{ proposal(id: #{proposal.id}) " \
                       "{ votes_for { edges { node { public_created_at } } } } }")

    votes = response["data"]["proposal"]["votes_for"]["edges"]
    expect(votes.count).to eq(2)
  end
end
