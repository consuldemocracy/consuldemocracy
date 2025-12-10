require "rails_helper"

describe "Moderate budget investments" do
  let(:budget)      { create(:budget) }
  let(:heading)     { create(:budget_heading, budget: budget, price: 666666) }
  let(:mod)         { create(:moderator) }
  let(:author)      { create(:user, username: "Julia") }
  let!(:investment) { create(:budget_investment, heading: heading, author: author) }

  scenario "Hiding an investment's author" do
    login_as(mod.user)
    visit budget_investment_path(budget, investment)

    accept_confirm("Are you sure? This will hide the user \"Julia\" and all their contents.") do
      click_button "Block author"
    end

    expect(page).to have_current_path(budget_investments_path(budget))
    expect(page).not_to have_content(investment.title)
  end
end
