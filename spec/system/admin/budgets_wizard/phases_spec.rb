require "rails_helper"

describe "Budgets wizard, phases step", :admin do
  let(:budget) { create(:budget, :drafting) }
  let!(:heading) { create(:budget_heading, budget: budget) }

  describe "Index" do
    scenario "back to a previous step" do
      heading.update!(name: "Main Park")

      visit admin_budgets_wizard_budget_budget_phases_path(budget)

      within "#side_menu" do
        expect(page).to have_css ".is-active", exact_text: "Participatory budgets"
      end

      click_link "Go back to headings"

      expect(page).to have_css "tr", text: "Main Park"
      expect(page).to have_css ".creation-timeline"
    end

    scenario "Enable and disable phases" do
      visit admin_budgets_wizard_budget_budget_phases_path(budget)

      within "tr", text: "Information" do
        expect(page).to have_content "Yes"

        click_button "Enable Information phase"

        expect(page).to have_content "No"
        expect(page).not_to have_content "Yes"
      end

      within "tr", text: "Reviewing voting" do
        expect(page).to have_content "Yes"

        click_button "Enable Reviewing voting phase"

        expect(page).to have_content "No"
        expect(page).not_to have_content "Yes"
      end

      click_link "Finish"

      expect(page).to have_css "section h3", exact_text: "Phases"

      within "tr", text: "Information" do
        expect(page).to have_content "No"
      end

      within "tr", text: "Reviewing voting" do
        expect(page).to have_content "No"
      end

      within "tr", text: "Accepting projects" do
        expect(page).to have_content "Yes"
      end

      within "tr", text: "Voting projects" do
        expect(page).to have_content "Yes"
      end
    end
  end

  describe "Edit" do
    scenario "update phase" do
      visit admin_budgets_wizard_budget_budget_phases_path(budget)

      expect(page).to have_css ".creation-timeline"

      within("tr", text: "Selecting projects") { click_link "Edit" }
      fill_in "Name", with: "Choosing projects"
      click_button "Save changes"

      expect(page).to have_content "Changes saved"
      expect(page).to have_css ".creation-timeline"
      within_table("Phases") { expect(page).to have_content "Choosing projects" }
    end

    scenario "submit the form with errors and then without errors" do
      phase = budget.phases.accepting

      visit edit_admin_budgets_wizard_budget_budget_phase_path(budget, phase)
      fill_in "Name", with: ""
      click_button "Save changes"

      expect(page).to have_css "#error_explanation"
      expect(page).to have_css ".creation-timeline"

      fill_in "Name", with: "Welcoming projects"
      click_button "Save changes"

      expect(page).to have_content "Changes saved"
      expect(page).to have_css ".creation-timeline"
      within_table("Phases") { expect(page).to have_content "Welcoming projects" }
    end

    scenario "update phase in single heading budget" do
      visit admin_budgets_wizard_budget_budget_phases_path(budget, mode: "single")

      within("tr", text: "Selecting projects") { click_link "Edit" }
      fill_in "Name", with: "Choosing projects"
      click_button "Save changes"

      expect(page).to have_content "Changes saved"
      expect(page).to have_css ".creation-timeline"
      within_table("Phases") { expect(page).to have_content "Choosing projects" }
      expect(page).to have_link "Go back to edit heading"
    end
  end
end
