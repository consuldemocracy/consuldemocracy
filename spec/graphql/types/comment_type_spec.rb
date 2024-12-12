require "rails_helper"

describe Types::CommentType do
  it "does not link author if public activity is set to false" do
    create(:user, :with_comment, username: "public",  public_activity: true)
    create(:user, :with_comment, username: "private", public_activity: false)

    response = execute("{ comments { edges { node { public_author { username } } } } }")
    received_authors = extract_fields(response, "comments", "public_author.username")

    expect(received_authors).to match_array ["public"]
  end

  it "only returns date and hour for created_at" do
    created_at = Time.zone.parse("2017-12-31 9:30:15")
    create(:comment, created_at: created_at)

    response = execute("{ comments { edges { node { public_created_at } } } }")
    received_timestamps = extract_fields(response, "comments", "public_created_at")

    expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
  end
end
