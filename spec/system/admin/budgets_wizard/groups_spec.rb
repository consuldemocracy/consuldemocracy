require "rails_helper"

describe "Budgets wizard, groups step", :admin do
  let(:budget) { create(:budget, :drafting) }

  describe "New" do
    scenario "create group" do
      visit admin_budgets_wizard_budget_groups_path(budget)

      within "#side_menu" do
        expect(page).to have_css ".is-active", exact_text: "Participatory budgets"
      end

      expect(page).to have_content "Continue to headings"
      expect(page).not_to have_link "Continue to headings"

      click_button "Add new group"

      fill_in "Group name", with: "All City"

      click_button "Create new group"

      expect(page).to have_content "Group created successfully!"
      expect(page).to have_content "All City"
      expect(page).to have_button "Add new group"
      expect(page).to have_link "Continue to headings"
    end

    scenario "cancel creating a group" do
      visit admin_budgets_wizard_budget_groups_path(budget)

      expect(page).not_to have_field "Group name"
      expect(page).not_to have_button "Cancel"
      expect(page).to have_content "Continue to headings"

      click_button "Add new group"

      expect(page).to have_field "Group name"
      expect(page).not_to have_button "Add new group"
      expect(page).not_to have_content "Continue to headings"

      click_button "Cancel"

      expect(page).to have_button "Add new group"
      expect(page).not_to have_field "Group name"
      expect(page).not_to have_button "Cancel"
      expect(page).to have_content "Continue to headings"
    end

    scenario "submit the form with errors" do
      visit admin_budgets_wizard_budget_groups_path(budget)
      click_button "Add new group"

      click_button "Create new group"

      expect(page).not_to have_content "Group created successfully!"
      expect(page).to have_css ".is-invalid-label", text: "Group name"
      expect(page).to have_css ".creation-timeline"
      expect(page).to have_content "can't be blank"
      expect(page).to have_button "Create new group"
      expect(page).to have_button "Cancel"
      expect(page).not_to have_button "Add new group"
      expect(page).not_to have_content "Continue to headings"
    end
  end

  describe "Edit" do
    scenario "update group" do
      create(:budget_group, budget: budget, name: "Group wiht a typo")

      visit admin_budgets_wizard_budget_groups_path(budget)

      expect(page).to have_css ".creation-timeline"

      within("tr", text: "Group wiht a typo") { click_link "Edit" }
      fill_in "Group name", with: "Group without typos"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"
      expect(page).to have_css ".creation-timeline"
      expect(page).to have_css "td", exact_text: "Group without typos"
    end

    scenario "submit the form with errors and then without errors" do
      group = create(:budget_group, budget: budget, name: "Group wiht a typo")

      visit edit_admin_budgets_wizard_budget_group_path(budget, group)
      fill_in "Group name", with: ""
      click_button "Save group"

      expect(page).to have_css "#error_explanation"

      fill_in "Group name", with: "Group without typos"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"
      expect(page).to have_css ".creation-timeline"
      expect(page).to have_css "td", exact_text: "Group without typos"
    end

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

      within "section", text: "Heading groups" do
        expect(page).to have_css "h4", exact_text: "Group without typos"
      end
    end
  end

  describe "Destroy" do
    scenario "delete a group without headings" do
      create(:budget_group, budget: budget, name: "Delete me!")

      visit admin_budgets_wizard_budget_groups_path(budget)
      within("tr", text: "Delete me!") { accept_confirm { click_button "Delete" } }

      expect(page).to have_content "Group deleted successfully"
      expect(page).not_to have_content "Delete me!"
      expect(page).to have_css ".creation-timeline"
    end

    scenario "try to delete a group with headings" do
      group = create(:budget_group, budget: budget, name: "Don't delete me!")
      create(:budget_heading, group: group)

      visit admin_budgets_wizard_budget_groups_path(budget)

      within("tr", text: "Don't delete me!") { accept_confirm { click_button "Delete" } }

      expect(page).to have_content "You cannot delete a Group that has associated headings"
      expect(page).to have_content "Don't delete me!"
      expect(page).to have_css ".creation-timeline"
    end
  end
end
