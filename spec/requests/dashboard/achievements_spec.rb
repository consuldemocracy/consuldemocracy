require "rails_helper"

describe Dashboard::AchievementsController do
  let(:proposal) { create(:proposal, created_at: 7.days.ago.beginning_of_month) }
  let(:executed_actions) { create_list(:dashboard_action, 8, :active, :proposed_action) }
  let!(:non_executed_actions) { create_list(:dashboard_action, 8, :active, :proposed_action) }

  before do
    sign_in(proposal.author)

    executed_actions.each_with_index do |action, index|
      create(:dashboard_executed_action, proposal: proposal, action: action,
                                         executed_at: proposal.created_at + index.days)
    end
  end

  it "returns a list of most recent executed achievements grouped by day" do
    get proposal_dashboard_achievements_path(proposal, format: :json)

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to eq(8)

    executed_actions.each do |action|
      expect(json.values.select { |a| a[:title] == action.title }).not_to be_empty
    end

    non_executed_actions.each do |action|
      expect(json.values.select { |a| a[:title] == action.title }).to be_empty
    end
  end

  it "returns a list of most recent executed achievements grouped by week" do
    get proposal_dashboard_achievements_path(proposal, group_by: "week", format: :json)

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to eq(2)
  end

  it "returns a list of most recent executed achievements grouped by month" do
    get proposal_dashboard_achievements_path(proposal, group_by: "month", format: :json)

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to eq(1)
  end
end
