require "rails_helper"

describe SettingsController do
  let(:created_at) { Time.now - 9.days }
  let(:proposal) { create(:proposal, created_at: created_at, published_at: created_at) }

  it "returns the proposal settings when authenticated" do
    sign_in(proposal.author)
    get :proposal, format: :json
    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(json.length).to be_positive
  end

  it "denies access to proposal settings when not authenticated" do
    get :proposal, format: :json
    expect(response).to have_http_status(403)
  end
end
