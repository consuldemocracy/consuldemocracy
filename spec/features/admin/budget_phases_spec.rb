require 'rails_helper'

feature 'Admin budget phases' do
  let(:budget) { create(:budget) }

  context 'Edit' do

    before do
      admin = create(:administrator)
      login_as(admin.user)
    end

    scenario 'Update phase' do
      visit edit_admin_budget_budget_phase_path(budget, budget.current_phase)

      fill_in 'start_date', with: Date.current + 1.days
      fill_in 'end_date', with: Date.current + 12.days
      fill_in 'budget_phase_summary', with: 'This is the summary of the phase.'
      fill_in 'budget_phase_description', with: 'This is the description of the phase.'
      uncheck 'budget_phase_enabled'
      click_button 'Save changes'

      expect(page).to have_current_path(edit_admin_budget_path(budget))
      expect(page).to have_content 'Changes saved'

      expect(budget.current_phase.starts_at.to_date).to eq((Date.current + 1.days).to_date)
      expect(budget.current_phase.ends_at.to_date).to eq((Date.current + 12.days).to_date)
      expect(budget.current_phase.summary).to eq('This is the summary of the phase.')
      expect(budget.current_phase.description).to eq('This is the description of the phase.')
      expect(budget.current_phase.enabled).to be(false)
    end
  end
end
