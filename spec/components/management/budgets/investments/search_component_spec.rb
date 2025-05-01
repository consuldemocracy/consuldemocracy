require "rails_helper"

describe Management::Budgets::Investments::SearchComponent do
  include Rails.application.routes.url_helpers

  let(:budget) { create(:budget) }
  let(:url) { management_budget_investments_path(budget) }
  let(:component) { Management::Budgets::Investments::SearchComponent.new(budget, url: url) }

  it "renders a label for each field" do
    render_inline component

    expect(page).to have_field "Search investments"
    expect(page).to have_select "Heading"
    expect(page).to have_field "Search unfeasible", type: :checkbox
  end
end
