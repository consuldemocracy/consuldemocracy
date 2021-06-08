require "rails_helper"

describe "Admin budget phases" do
  let(:budget) { create(:budget) }

  context "Edit", :admin do
    scenario "Update phase" do
      visit edit_admin_budget_budget_phase_path(budget, budget.current_phase)

      fill_in "start_date", with: Date.current + 1.day
      fill_in "end_date", with: Date.current + 12.days
      fill_in_ckeditor "Description", with: "New description of the phase."
      uncheck "budget_phase_enabled"
      click_button "Save changes"

      expect(page).to have_current_path(admin_budget_path(budget))
      expect(page).to have_content "Changes saved"

      expect(budget.current_phase.starts_at.to_date).to eq((Date.current + 1.day).to_date)
      expect(budget.current_phase.ends_at.to_date).to eq((Date.current + 12.days).to_date)
      expect(budget.current_phase.description).to include("New description of the phase.")
      expect(budget.current_phase.enabled).to be(false)
    end

    scenario "Show default phase name or custom if present" do
      visit edit_admin_budget_path(budget)
      phase = budget.current_phase

      within "#budget_phase_#{phase.id}" do
        expect(page).to have_content "Accepting projects"
        expect(page).not_to have_content "My phase custom name"
        click_link "Edit phase"
      end

      fill_in "Phase's Name", with: "My phase custom name"
      click_button "Save changes"

      within "#budget_phase_#{phase.id}" do
        expect(page).to have_content "My phase custom name"
        expect(page).to have_content "(Accepting projects)"
      end
    end

    scenario "Show CTA button in public site if added" do
      visit edit_admin_budget_budget_phase_path(budget, budget.current_phase)
      expect(page).to have_content "Main call to action (optional)"

      fill_in "Text on the button", with: "Button on the phase"
      fill_in "The button takes you to (add a link)", with: "https://consulproject.org"
      click_button "Save changes"

      visit budgets_path
      within "##{budget.current_phase.kind.parameterize}" do
        expect(page).to have_link("Button on the phase", href: "https://consulproject.org")
      end
    end

    scenario "Enable and disable a phase is possible from the budget view" do
      visit edit_admin_budget_path(budget)
      phase = budget.phases.enabled.sample

      expect(phase.enabled).to be true
      within "#budget_phase_#{phase.id}" do
        expect(find("#phase_enabled")).to be_checked
        uncheck "phase_enabled"
      end

      visit edit_admin_budget_path(budget)

      within "#budget_phase_#{phase.id}" do
        expect(find("#phase_enabled")).not_to be_checked
        expect(phase.reload.enabled).to be false
        check "phase_enabled"
      end

      visit edit_admin_budget_path(budget)

      within "#budget_phase_#{phase.id}" do
        expect(find("#phase_enabled")).to be_checked
      end
      expect(phase.reload.enabled).to be true
    end

    scenario "Phase dates can overlap" do
      visit edit_admin_budget_budget_phase_path(budget, budget.published_phases.first)

      fill_in "start_date", with: "01/01/2020"
      fill_in "end_date", with: "03/03/2020"
      click_button "Save changes"

      visit edit_admin_budget_budget_phase_path(budget, budget.published_phases.last)

      fill_in "start_date", with: "02/02/2020"
      fill_in "end_date", with: "04/04/2020"
      click_button "Save changes"

      expect(budget.published_phases.first.starts_at.to_date).to eq(("01/01/2020").to_date)
      expect(budget.published_phases.last.starts_at.to_date).to eq(("02/02/2020").to_date)
      expect(budget.published_phases.first.ends_at.to_date).to eq(("03/03/2020").to_date)
      expect(budget.published_phases.last.ends_at.to_date).to eq(("04/04/2020").to_date)
      expect(budget.published_phases.first.enabled).to be(true)
      expect(budget.published_phases.last.enabled).to be(true)
    end
  end
end
