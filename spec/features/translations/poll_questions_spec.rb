# coding: utf-8
require 'rails_helper'

feature "Translations" do

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

    context "Questions" do

      let(:question) { create(:poll_question, poll: poll,
                                              title_en: "Question in English",
                                              title_es: "Pregunta en Español") }

      before do
        @edit_question_url = edit_admin_question_path(question)
      end

      context "Poll select box" do

        scenario "translates the poll name in options", :js do
          visit @edit_question_url

          expect(page).to have_select('poll_question_poll_id', options: [poll.name_en])

          select('Español', from: 'locale-switcher')

          expect(page).to have_select('poll_question_poll_id', options: [poll.name_es])
        end

        scenario "uses fallback if name is not translated to current locale", :js do
          visit @edit_question_url

          expect(page).to have_select('poll_question_poll_id', options: [poll.name_en])

          select('Français', from: 'locale-switcher')

          expect(page).to have_select('poll_question_poll_id', options: [poll.name_es])
        end
      end

      scenario "Add a translation", :js do
        visit @edit_question_url

        select "Français", from: "translation_locale"
        fill_in 'poll_question_title_fr', with: 'Question en Français'

        click_button 'Save'
        expect(page).to have_content "Changes saved"

        visit @edit_question_url
        expect(page).to have_field('poll_question_title_en', with: 'Question in English')

        click_link "Español"
        expect(page).to have_field('poll_question_title_es', with: 'Pregunta en Español')

        click_link "Français"
        expect(page).to have_field('poll_question_title_fr', with: 'Question en Français')
      end

      scenario "Update a translation", :js do
        visit @edit_question_url

        click_link "Español"
        fill_in 'poll_question_title_es', with: 'Pregunta correcta en Español'

        click_button 'Save'
        expect(page).to have_content "Changes saved"

        visit poll_path(poll)
        expect(page).to have_content("Question in English")

        select('Español', from: 'locale-switcher')
        expect(page).to have_content("Pregunta correcta en Español")
      end

      scenario "Remove a translation", :js do
        visit @edit_question_url

        click_link "Español"
        click_link "Remove language"

        expect(page).not_to have_link "Español"

        click_button "Save"
        visit @edit_question_url
        expect(page).not_to have_link "Español"
      end

      context "Globalize javascript interface" do

        scenario "Highlight current locale", :js do
          visit @edit_question_url

          expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

          select('Español', from: 'locale-switcher')

          expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
        end

        scenario "Highlight selected locale", :js do
          visit @edit_question_url

          expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

          click_link "Español"

          expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
        end

        scenario "Show selected locale form", :js do
          visit @edit_question_url

          expect(page).to have_field('poll_question_title_en', with: 'Question in English')

          click_link "Español"

          expect(page).to have_field('poll_question_title_es', with: 'Pregunta en Español')
        end

        scenario "Select a locale and add it to the poll form", :js do
          visit @edit_question_url

          select "Français", from: "translation_locale"

          expect(page).to have_link "Français"

          click_link "Français"

          expect(page).to have_field('poll_question_title_fr')
        end
      end
    end
  end
end
