require "rails_helper"

describe Shared::TagCloudComponent do
  include Rails.application.routes.url_helpers

  it "links each proposal tag to its search" do
    create(:proposal, tag_list: "Parks")

    render_inline Shared::TagCloudComponent.new("Proposal")

    expect(page).to have_link "Parks", href: proposals_path(search: "Parks")
  end

  it "links each debate tag to its search" do
    create(:debate, tag_list: "Parks")

    render_inline Shared::TagCloudComponent.new("Debate")

    expect(page).to have_link "Parks", href: debates_path(search: "Parks")
  end

  it "links each investment tag to the budget search" do
    budget = create(:budget)
    heading = create(:budget_heading, budget: budget)
    create(:budget_investment, heading: heading, tag_list: "Parks")

    with_request_url(budget_investments_path(budget)) do
      render_inline Shared::TagCloudComponent.new("Budget::Investment")
    end

    expect(page).to have_link "Parks", href: budget_investments_path(budget, search: "Parks")
  end
end
