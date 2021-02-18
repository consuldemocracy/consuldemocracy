require "rails_helper"

describe "Admin budget phases" do
  let(:budget) { create(:budget) }

  context "Edit", :admin do
    scenario "Update phase", :js do
      visit edit_admin_budget_budget_phase_path(budget, budget.current_phase)

      fill_in "start_date", with: Date.current + 1.day
      fill_in "end_date", with: Date.current + 12.days
      fill_in_ckeditor "Summary", with: "New summary of the phase."
      fill_in_ckeditor "Description", with: "New description of the phase."
      uncheck "budget_phase_enabled"
      click_button "Save changes"

      expect(page).to have_current_path(edit_admin_budget_path(budget))
      expect(page).to have_content "Changes saved"

      expect(budget.current_phase.starts_at.to_date).to eq((Date.current + 1.day).to_date)
      expect(budget.current_phase.ends_at.to_date).to eq((Date.current + 12.days).to_date)
      expect(budget.current_phase.summary).to include("New summary of the phase.")
      expect(budget.current_phase.description).to include("New description of the phase.")
      expect(budget.current_phase.enabled).to be(false)
    end
  end
end
