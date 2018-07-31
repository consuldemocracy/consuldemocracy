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

  context "Polls" do

    let(:poll) { create(:poll, name_en: "Name in English",
                               name_es: "Nombre en Español",
                               summary_en: "Summary in English",
                               summary_es: "Resumen en Español",
                               description_en: "Description in English",
                               description_es: "Descripción en Español") }

    background do
      admin = create(:administrator)
      login_as(admin.user)
    end

    before do
      @edit_poll_url = edit_admin_poll_path(poll)
    end

    scenario "Add a translation", :js do
      visit @edit_poll_url

      select "Français", from: "translation_locale"
      fill_in 'poll_description_fr', with: 'Description en Français'

      click_button 'Update poll'
      expect(page).to have_content "Poll updated successfully"

      visit @edit_poll_url
      expect(page).to have_field('poll_name_en', with: 'Name in English')
      expect(page).to have_field('poll_summary_en', with: 'Summary in English')
      expect(page).to have_field('poll_description_en', with: 'Description in English')

      click_link "Español"
      expect(page).to have_field('poll_name_es', with: 'Nombre en Español')
      expect(page).to have_field('poll_summary_es', with: 'Resumen en Español')
      expect(page).to have_field('poll_description_es', with: 'Descripción en Español')

      click_link "Français"
      expect(page).to have_field('poll_name_fr', with: 'Name en Français')
      expect(page).to have_field('poll_summary_fr', with: 'Summary en Français')
      expect(page).to have_field('poll_description_fr', with: 'Description en Français')
    end

    scenario "Update a translation", :js do
      visit @edit_poll_url

      click_link "Español"
      fill_in 'poll_description_es', with: 'Descripción correcta en Español'

      click_button 'Update poll'
      expect(page).to have_content "Poll updated successfully"

      visit poll_path(poll)
      expect(page).to have_content("Name in English")
      expect(page).to have_content("Summary in English")
      expect(page).to have_content("Description in English")

      select('Español', from: 'locale-switcher')
      expect(page).to have_content("Nombre correcto en Español")
      expect(page).to have_content("Resumen correcto en Español")
      expect(page).to have_content("Descripción correcta en Español")
    end

    scenario "Remove a translation", :js do
      visit @edit_poll_url

      click_link "Español"
      click_link "Remove language"

      expect(page).not_to have_link "Español"

      click_button "Update poll"
      visit @edit_poll_url
      expect(page).not_to have_link "Español"
    end

    context "Globalize javascript interface" do

      scenario "Highlight current locale", :js do
        visit @edit_poll_url

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        select('Español', from: 'locale-switcher')

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Highlight selected locale", :js do
        visit @edit_poll_url

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        click_link "Español"

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Show selected locale form", :js do
        visit @edit_poll_url

        expect(page).to have_field('poll_description_en', with: 'Description in English')

        click_link "Español"

        expect(page).to have_field('poll_description_es', with: 'Descripción en Español')
      end

      scenario "Select a locale and add it to the poll form", :js do
        visit @edit_poll_url

        select "Français", from: "translation_locale"

        expect(page).to have_link "Français"

        click_link "Français"

        expect(page).to have_field('poll_description_fr')
      end
    end

  end

end
