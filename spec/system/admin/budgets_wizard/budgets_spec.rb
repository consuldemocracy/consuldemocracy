require "rails_helper"

describe "Budgets wizard, first step", :admin do
  describe "New" do
    scenario "Create budget - Knapsack voting (default)" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "M30 - Summer campaign"
      fill_in "Text on the link", with: "Participate now!"
      fill_in "The link takes you to (add a link)", with: "https://consulproject.org"
      fill_in "Name", with: "M30 - Summer campaign"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"

      click_link "Go back to edit budget"

      expect(page).to have_field "Name", with: "M30 - Summer campaign"
      expect(page).to have_select "Final voting style", selected: "Knapsack"
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
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "M30 - Summer campaign"

      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"

      within("#side_menu") { click_link "Participatory budgets" }
      within("tr", text: "M30 - Summer campaign") { click_link "Edit" }

      expect(page).to have_content "This participatory budget is in draft mode"
      expect(page).to have_link "Preview"
      expect(page).to have_button "Publish budget"
    end

    scenario "Create budget - Approval voting with hide money" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      expect(page).to have_select("Final voting style", selected: "Knapsack")
      expect(page).not_to have_selector("#budget_hide_money")

      fill_in "Name", with: "Budget hide money"
      select "Approval", from: "Final voting style"
      check "Hide money amount for this budget"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"
      expect(page).to have_content "Budget hide money"
      expect(Budget.last.voting_style).to eq "approval"
      expect(Budget.last.hide_money?).to be true
    end

    scenario "Creation a budget with hide money by steps" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "Multiple headings budget with hide money"
      select "Approval", from: "Final voting style"
      check "Hide money amount for this budget"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"
      expect(page).to have_content "There are no groups."

      click_button "Add new group"
      fill_in "Group name", with: "All city"
      click_button "Create new group"
      expect(page).to have_content "Group created successfully!"
      within("table") { expect(page).to have_content "All city" }
      expect(page).not_to have_content "There are no groups."

      click_link "Continue to headings"
      expect(page).to have_content "Multiple headings budget with hide money / All city headings"
      expect(page).to have_content "There are no headings in the All city group."

      click_button "Add new heading"
      fill_in "Heading name", with: "All city"
      click_button "Create new heading"
      expect(page).to have_content "Heading created successfully!"
      expect(page).to have_content "All city"
      expect(page).to have_link "Continue to phases"
      expect(page).not_to have_content "There are no headings."
      expect(page).not_to have_content "Money amount"
      expect(page).not_to have_content "€"
    end
  end

  describe "Edit" do
    scenario "update budget" do
      budget = create(:budget, name: "Budget wiht typo")

      visit admin_budgets_wizard_budget_groups_path(budget)

      click_link "Go back to edit budget"

      expect(page).to have_content "Edit Participatory budget"
      expect(page).to have_css ".creation-timeline"
      expect(page).to have_field "Name", with: "Budget wiht typo"

      fill_in "Name", with: "Budget without typos"
      click_button "Continue to groups"

      expect(page).to have_content "Participatory budget updated successfully"
      expect(page).to have_content "Budget without typos"
      expect(page).to have_css ".creation-timeline"
      expect(page).to have_content "There are no groups"
    end

    scenario "submit the form with errors and then without errors" do
      budget = create(:budget, name: "Budget wiht typo")

      visit edit_admin_budgets_wizard_budget_path(budget)
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
