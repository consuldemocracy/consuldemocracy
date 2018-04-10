require 'rails_helper'

feature "Translations" do

  context "Milestones" do

    let(:investment) { create(:budget_investment) }

    background do
      admin = create(:administrator)
      login_as(admin.user)
    end

    scenario "Add a translation", :js, :focus do
      milestone = create(:budget_investment_milestone, description: "Description in English")

      edit_milestone_url = edit_admin_budget_budget_investment_budget_investment_milestone_path(investment.budget, investment, milestone)
      visit edit_milestone_url

      select "Español", from: "translation_locale"
      fill_in 'budget_investment_milestone_description_es', with: 'Descripción en Español'

      click_button 'Update milestone'
      expect(page).to have_content "Milestone updated successfully"

      visit edit_milestone_url
      expect(page).to have_field('budget_investment_milestone_description_en', with: 'Description in English')

      click_link "Español"
      expect(page).to have_field('budget_investment_milestone_description_es', with: 'Descripción en Español')
    end

    scenario "Update a translation", :js, :focus do
      milestone = create(:budget_investment_milestone,
                         investment: investment,
                         description_en: "Description in English",
                         description_es: "Descripción en Español")

      edit_milestone_url = edit_admin_budget_budget_investment_budget_investment_milestone_path(investment.budget, investment, milestone)
      visit edit_milestone_url

      select "Español", from: "translation_locale"
      fill_in 'budget_investment_milestone_description_es', with: 'Descripción correcta en Español'

      click_button 'Update milestone'
      expect(page).to have_content "Milestone updated successfully"

      visit budget_investment_path(investment.budget, investment)

      click_link("Milestones (1)")
      expect(page).to have_content("Description in English")

      select('Español', from: 'locale-switcher')
      click_link("Seguimiento (1)")

      expect(page).to have_content("Descripción correcta en Español")
    end

  end

end