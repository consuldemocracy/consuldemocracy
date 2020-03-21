require "rails_helper"

describe "Budgets wizard, first step", :admin do
  describe "New" do
    scenario "Create budget - Knapsack voting (default)" do
      visit admin_budgets_path
      click_link "Create new budget"

      fill_in "Name", with: "M30 - Summer campaign"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"

      click_link "Go back to budgets"

      expect(page).to have_field "Name", with: "M30 - Summer campaign"
      expect(page).to have_select "Final voting style", selected: "Knapsack"
    end

    scenario "Create budget - Approval voting" do
      admin = Administrator.first

      visit admin_budgets_path
      click_link "Create new budget"

      fill_in "Name", with: "M30 - Summer campaign"
      select "Approval", from: "Final voting style"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"

      click_link "Go back to budgets"

      expect(page).to have_field "Name", with: "M30 - Summer campaign"
      expect(page).to have_select "Final voting style", selected: "Approval"

      click_link "Select administrators"

      expect(page).to have_field admin.name
    end

    scenario "Submit the form with errors" do
      visit new_admin_budgets_wizard_budget_path
      click_button "Continue to groups"

      expect(page).not_to have_content "New participatory budget created successfully!"
      expect(page).to have_css ".is-invalid-label", text: "Name"
      expect(page).to have_css ".creation-timeline"
    end

    scenario "Name should be unique" do
      create(:budget, name: "Existing Name")

      visit new_admin_budgets_wizard_budget_path
      fill_in "Name", with: "Existing Name"
      click_button "Continue to groups"

      expect(page).not_to have_content "New participatory budget created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Name")
      expect(page).to have_css("small.form-error", text: "has already been taken")
    end

    scenario "Do not show results and stats settings on new budget" do
      visit new_admin_budgets_wizard_budget_path

      expect(page).not_to have_content "Show results and stats"
      expect(page).not_to have_field "Show results"
      expect(page).not_to have_field "Show stats"
      expect(page).not_to have_field "Show advanced stats"
    end
  end

  describe "Create" do
    scenario "A new budget is always created in draft mode" do
      visit admin_budgets_path
      click_link "Create new budget"

      fill_in "Name", with: "M30 - Summer campaign"

      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"

      click_link "Go back to budgets"

      expect(page).to have_content "This participatory budget is in draft mode"
      expect(page).to have_link "Preview budget"
      expect(page).to have_link "Publish budget"
    end
  end
end
