require "rails_helper"

describe "Budgets wizard, first step", :admin do
  describe "New" do
    scenario "Create budget with Knapsack voting and in draft mode (default)" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "M30 - Summer campaign"
      fill_in "Text on the link", with: "Participate now!"
      fill_in "The link takes you to (add a link)", with: "https://consuldemocracy.org"

      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"

      click_link "Go back to edit budget"

      expect(page).to have_field "Name", with: "M30 - Summer campaign"
      expect(page).to have_select "Final voting style", selected: "Knapsack"

      within("#side_menu") { click_link "Participatory budgets" }
      within("tr", text: "M30 - Summer campaign") { click_link "Edit" }

      expect(page).to have_content "This participatory budget is in draft mode"
      expect(page).to have_link "Preview"
      expect(page).to have_button "Publish budget"
    end

    scenario "Create budget - Approval voting" do
      admin = Administrator.first

      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "M30 - Summer campaign"
      select "Approval", from: "Final voting style"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"

      click_link "Go back to edit budget"

      expect(page).to have_field "Name", with: "M30 - Summer campaign"
      expect(page).to have_select "Final voting style", selected: "Approval"

      click_link "Select administrators"

      expect(page).to have_field admin.name
    end

    scenario "Submit the form with errors" do
      visit new_admin_budgets_wizard_budget_path
      click_button "Continue to groups"

      expect(page).to have_css ".is-invalid-label", text: "Name"
      expect(page).to have_css ".creation-timeline"
      expect(page).not_to have_content "New participatory budget created successfully!"
    end

    scenario "Name should be unique" do
      create(:budget, name: "Existing Name")

      visit new_admin_budgets_wizard_budget_path
      fill_in "Name", with: "Existing Name"
      click_button "Continue to groups"

      expect(page).to have_css(".is-invalid-label", text: "Name")
      expect(page).to have_css("small.form-error", text: "has already been taken")
      expect(page).not_to have_content "New participatory budget created successfully!"
    end

    scenario "Do not show results and stats settings on new budget" do
      visit new_admin_budgets_wizard_budget_path

      expect(page).not_to have_content "Show results and stats"
      expect(page).not_to have_field "Show results"
      expect(page).not_to have_field "Show stats"
      expect(page).not_to have_field "Show advanced stats"
    end
  end

  describe "Edit" do
    scenario "update budget with errors and then without errors" do
      budget = create(:budget, name: "Budget wiht typo")

      visit edit_admin_budgets_wizard_budget_path(budget)

      expect(page).to have_content "Edit Participatory budget"
      expect(page).to have_css ".creation-timeline"
      expect(page).to have_field "Name", with: "Budget wiht typo"

      fill_in "Name", with: ""
      click_button "Continue to groups"

      expect(page).to have_css "#error_explanation"

      fill_in "Name", with: "Budget without typos"
      click_button "Continue to groups"

      expect(page).to have_content "Participatory budget updated successfully"
      expect(page).to have_content "Budget without typos"
      expect(page).to have_css ".creation-timeline"
      expect(page).to have_content "There are no groups"
    end
  end
end
