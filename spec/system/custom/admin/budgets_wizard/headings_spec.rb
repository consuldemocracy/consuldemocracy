require "rails_helper"

describe "Budgets wizard, headings step", :admin do
  let(:budget) { create(:budget, :drafting) }
  let(:group) { create(:budget_group, budget: budget, name: "Default group") }

  describe "Edit" do
    scenario "update heading in single heading budget" do
      visit admin_budgets_wizard_budget_group_headings_path(budget, group, mode: "single")
      fill_in "Heading name", with: "Heading wiht typo"
      fill_in "Money amount", with: "300000"
      click_button "Continue to phases"

      expect(page).to have_content "Heading created successfully"

      click_link "Go back to edit heading"

      expect(page).to have_field "Heading name", with: "Heading wiht typo"

      fill_in "Heading name", with: "Heading without typos"
      click_button "Continue to phases"

      expect(page).to have_content "Heading updated successfully"

      visit admin_budget_path(budget)

      within "section", text: "HEADING GROUPS" do
        within("tbody tr") { expect(page).to have_content "Heading without typos" }
      end
    end
  end
end
