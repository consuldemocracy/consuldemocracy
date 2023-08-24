require "rails_helper"

describe "Budgets wizard, groups step", :admin do
  let(:budget) { create(:budget, :drafting) }

  describe "Edit" do
    scenario "update group in single heading budget" do
      visit admin_budgets_wizard_budget_groups_path(budget, mode: "single")
      fill_in "Group name", with: "Group wiht typo"
      click_button "Continue to headings"

      click_link "Go back to edit group"

      expect(page).to have_field "Group name", with: "Group wiht typo"

      fill_in "Group name", with: "Group without typos"
      click_button "Continue to headings"

      expect(page).to have_content "Group updated successfully"

      visit admin_budget_path(budget)

      within "section", text: "HEADING GROUPS" do
        expect(page).to have_css "h4", exact_text: "Group without typos"
      end
    end
  end
end
