require "rails_helper"

describe "Sensemaker budget jobs redirect" do
  include Rails.application.routes.url_helpers

  let(:budget) { create(:budget) }

  it "redirects to budget sensemaking path with 301" do
    get sensemaker_budget_jobs_path(budget)

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to(budget_sensemaking_path(budget))
  end
end
