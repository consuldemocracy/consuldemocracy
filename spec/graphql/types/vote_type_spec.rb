require "rails_helper"

describe Types::VoteType do
  it "only returns date and hour for created_at" do
    created_at = Time.zone.parse("2017-12-31 9:30:15")
    vote = create(:vote, created_at: created_at)

    response = run_graphql_field("Vote.public_created_at", vote)

    expect(Time.zone.parse(response.to_s)).to eq Time.zone.parse("2017-12-31 09:00:00")
  end
end
