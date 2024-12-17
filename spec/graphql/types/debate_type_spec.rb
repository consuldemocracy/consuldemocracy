require "rails_helper"

describe Types::DebateType do
  it "does not link author if public activity is set to false" do
    create(:user, :with_debate, username: "public",  public_activity: true)
    create(:user, :with_debate, username: "private", public_activity: false)

    response = execute("{ debates { edges { node { public_author { username } } } } }")
    received_authors = extract_fields(response, "debates", "public_author.username")

    expect(received_authors).to match_array ["public"]
  end

  it "only returns date and hour for created_at" do
    created_at = Time.zone.parse("2017-12-31 9:30:15")
    create(:debate, created_at: created_at)

    response = execute("{ debates { edges { node { public_created_at } } } }")
    received_timestamps = extract_fields(response, "debates", "public_created_at")

    expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
  end

  it "only returns tags with kind nil or category" do
    create(:tag, name: "Parks")
    create(:tag, :category, name: "Health")
    create(:tag, name: "Admin tag", kind: "admin")

    debate = create(:debate, tag_list: "Parks, Health, Admin tag")

    response = execute("{ debate(id: #{debate.id}) { tags  { edges { node { name } } } } }")
    received_tags = dig(response, "data.debate.tags.edges").map { |node| node["node"]["name"] }

    expect(received_tags).to match_array ["Parks", "Health"]
  end
end
