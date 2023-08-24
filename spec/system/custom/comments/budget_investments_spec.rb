require "rails_helper"

describe "Commenting Budget::Investments" do
  let(:user) { create :user }
  let(:investment) { create :budget_investment }

  scenario "Show order links only if there are comments" do
    visit budget_investment_path(investment.budget, investment)

    within "#tab-comments" do
      expect(page).not_to have_link "Most voted"
      expect(page).not_to have_link "Newest first"
      expect(page).not_to have_link "Oldest first"
    end

    create(:comment, commentable: investment, user: user)
    visit budget_investment_path(investment.budget, investment)

    within "#tab-comments" do
      expect(page).to have_link "Most voted"
      expect(page).to have_link "Newest first"
      expect(page).to have_link "Oldest first"
    end
  end
end
