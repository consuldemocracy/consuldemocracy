require "rails_helper"

describe Types::ProposalNotificationType do
  it "only returns date and hour for created_at" do
    created_at = Time.zone.parse("2017-12-31 9:30:15")
    create(:proposal_notification, created_at: created_at)

    response = execute("{ proposal_notifications { edges { node { public_created_at } } } }")
    received_timestamps = extract_fields(response, "proposal_notifications", "public_created_at")

    expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
  end

  it "only links proposal if public" do
    visible_proposal = create(:proposal, title: "Visible")
    hidden_proposal  = create(:proposal, :hidden, title: "Hidden")

    create(:proposal_notification, proposal: visible_proposal)
    create(:proposal_notification, proposal: hidden_proposal)

    response = execute("{ proposal_notifications { edges { node { proposal { title } } } } }")
    received_proposals = extract_fields(response, "proposal_notifications", "proposal.title")

    expect(received_proposals).to match_array ["Visible"]
  end
end
