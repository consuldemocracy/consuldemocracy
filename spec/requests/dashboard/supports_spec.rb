require "rails_helper"

describe Dashboard::GroupSupports do
  let(:created_at) { Time.current - 9.days }
  let(:proposal) { create(:proposal, created_at: created_at, published_at: created_at) }

  before do
    8.times do |i|
      user = create(:user, :verified)
      Vote.create!(votable: proposal, voter: user, vote_weight: 1,
                   created_at: proposal.created_at + i.days,
                   updated_at: proposal.created_at + i.days)
    end

    sign_in(proposal.author)
  end

  it "returns the number of supports grouped by day" do
    get proposal_dashboard_supports_path(proposal, format: :json)

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to eq(10)
    expect(json.values.last).to eq(8)
  end

  it "returns the number of supports grouped by week" do
    get proposal_dashboard_supports_path(proposal, group_by: "week", format: :json)

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to be >= 2
    expect(json.length).to be <= 3
    expect(json.values.last).to eq(8)
  end

  it "returns the number of supports grouped by month" do
    get proposal_dashboard_supports_path(proposal, group_by: "month", format: :json)

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to be >= 1
    expect(json.length).to be <= 2
    expect(json.values.last).to eq(8)
  end
end
