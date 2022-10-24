require "rails_helper"

describe "Admin change log" do
  let(:administrator) { create(:administrator, user: create(:user, username: "Ana")) }
  before { login_as(administrator.user) }

  context "Investments Participatory Budgets" do
    scenario "Changes" do
      investment = create(:budget_investment, title: "Good old times")

      visit admin_budget_budget_investment_path(investment.budget, investment)

      expect(page).to have_content "There are no changes logged"

      click_link "Edit"
      fill_in "Title", with: "Modern times"
      click_button "Update"

      expect(page).not_to have_content "There are no changes logged"
      expect(page).to have_content "Change Log"

      within("#audits thead") do
        expect(page).to have_content "Field"
        expect(page).to have_content "Old Value"
        expect(page).to have_content "New Value"
        expect(page).to have_content "Edited at"
        expect(page).to have_content "Edited by"
      end

      within("#audits tbody") do
        expect(page).to have_content "Title"
        expect(page).to have_content "Good old times"
        expect(page).to have_content "Modern times"
        expect(page).to have_content "Ana"
      end
    end
  end
end
