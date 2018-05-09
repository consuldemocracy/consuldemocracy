require 'rails_helper'

feature "Translations" do

  context "Milestones" do

    let(:investment) { create(:budget_investment) }
    let(:milestone) { create(:budget_investment_milestone,
                              investment: investment,
                              description_en: "Description in English",
                              description_es: "Descripción en Español") }

    background do
      admin = create(:administrator)
      login_as(admin.user)
    end

    before do
      @edit_milestone_url = edit_admin_budget_budget_investment_budget_investment_milestone_path(investment.budget, investment, milestone)
    end

    scenario "Add a translation", :js do
      visit @edit_milestone_url

      select "Français", from: "translation_locale"
      fill_in 'budget_investment_milestone_description_fr', with: 'Description en Français'

      click_button 'Update milestone'
      expect(page).to have_content "Milestone updated successfully"

      visit @edit_milestone_url
      expect(page).to have_field('budget_investment_milestone_description_en', with: 'Description in English')

      click_link "Español"
      expect(page).to have_field('budget_investment_milestone_description_es', with: 'Descripción en Español')

      click_link "Français"
      expect(page).to have_field('budget_investment_milestone_description_fr', with: 'Description en Français')
    end

    scenario "Update a translation", :js do
      visit @edit_milestone_url

      click_link "Español"
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

    scenario "Remove a translation", :js do
      visit @edit_milestone_url

      click_link "Español"
      click_link "Remove language"

      expect(page).not_to have_link "Español"

      click_button "Update milestone"
      visit @edit_milestone_url
      expect(page).not_to have_link "Español"
    end

    context "Globalize javascript interface" do

      scenario "Highlight current locale", :js do
        visit @edit_milestone_url

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        select('Español', from: 'locale-switcher')

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Highlight selected locale", :js do
        visit @edit_milestone_url

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        click_link "Español"

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Show selected locale form", :js do
        visit @edit_milestone_url

        expect(page).to have_field('budget_investment_milestone_description_en', with: 'Description in English')

        click_link "Español"

        expect(page).to have_field('budget_investment_milestone_description_es', with: 'Descripción en Español')
      end

      scenario "Select a locale and add it to the milestone form", :js do
        visit @edit_milestone_url

        select "Français", from: "translation_locale"

        expect(page).to have_link "Français"

        click_link "Français"

        expect(page).to have_field('budget_investment_milestone_description_fr')
      end
    end

  end

end
