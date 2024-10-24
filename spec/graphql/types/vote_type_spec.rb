require "rails_helper"

describe Types::VoteType do
  it "only returns date and hour for created_at" do
    created_at = Time.zone.parse("2017-12-31 9:30:15")
    create(:vote, created_at: created_at)

    response = execute("{ votes { edges { node { public_created_at } } } }")
    received_timestamps = extract_fields(response, "votes", "public_created_at")

    expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
  end
end
