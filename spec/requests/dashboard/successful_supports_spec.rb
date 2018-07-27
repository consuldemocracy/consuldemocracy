require 'rails_helper'

describe "Retrieves number of supports for the successful proposal" do
  let(:created_at) { DateTime.parse("2018-01-01 12:00:00") }
  let(:proposal) { create(:proposal, created_at: created_at) }

  before do
    @successful_proposal_id = Setting['proposals.successful_proposal_id']
    Setting['proposals.successful_proposal_id'] = proposal.id

    8.times do |i|
      user = create(:user, :verified)
      Vote.create!(
        votable: proposal, 
        voter: user, 
        vote_weight: 1, 
        created_at: proposal.created_at + i.days, 
        updated_at: proposal.created_at + i.days
      )
    end

    sign_in(proposal.author)
  end

  after do
    Setting['proposals.successful_proposal_id'] = @successful_proposal_id
  end

  it "returns the number of supports grouped by day" do
    get proposal_dashboard_successful_supports_path(proposal, format: :json)

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to eq(8)
    expect(json.values.last).to eq(8)
  end

  it "returns the number of supports grouped by week" do
    get proposal_dashboard_successful_supports_path(proposal, group_by: 'week', format: :json)

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to eq(2)
    expect(json.values.last).to eq(8)
  end

  it "returns the number of supports grouped by month" do
    get proposal_dashboard_successful_supports_path(proposal, group_by: 'month', format: :json)

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to eq(1)
    expect(json.values.last).to eq(8)
  end
end
