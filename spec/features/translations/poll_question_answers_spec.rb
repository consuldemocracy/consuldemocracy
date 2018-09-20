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

      context "Answers" do

        let(:answer) { create(:poll_question_answer, question: question,
                                                     title_en: "Answer in English",
                                                     title_es: "Respuesta en Español",
                                                     description_en: "Description in English",
                                                     description_es: "Descripción en Español") }

        before do
          @edit_answer_url = edit_admin_answer_path(answer)
        end

        scenario "Add a translation", :js do
          visit @edit_answer_url

          select "Français", from: "translation_locale"
          fill_in 'poll_question_answer_title_fr', with: 'Answer en Français'
          fill_in_ckeditor 'poll_question_answer_description_fr', with: 'Description en Français'

          click_button 'Save'
          expect(page).to have_content "Changes saved"

          expect(page).to have_content "Answer in English"
          expect(page).to have_content "Description in English"

          select('Español', from: 'locale-switcher')
          expect(page).to have_content "Respuesta en Español"
          expect(page).to have_content "Descripción en Español"

          select('Français', from: 'locale-switcher')
          expect(page).to have_content "Answer en Français"
          expect(page).to have_content "Description en Français"
        end

        scenario "Update a translation", :js do
          visit @edit_answer_url

          click_link "Español"
          fill_in 'poll_question_answer_title_es', with: 'Pregunta correcta en Español'
          fill_in_ckeditor 'poll_question_answer_description_es', with: 'Descripción correcta en Español'

          click_button 'Save'
          expect(page).to have_content "Changes saved"

          expect(page).to have_content("Answer in English")
          expect(page).to have_content("Description in English")

          select('Español', from: 'locale-switcher')
          expect(page).to have_content("Pregunta correcta en Español")
          expect(page).to have_content("Descripción correcta en Español")
        end

        scenario "Remove a translation", :js do
          visit @edit_answer_url

          click_link "Español"
          click_link "Remove language"

          expect(page).not_to have_link "Español"

          click_button "Save"
          visit @edit_answer_url
          expect(page).not_to have_link "Español"
        end

        context "Globalize javascript interface" do

          scenario "Highlight current locale", :js do
            visit @edit_answer_url

            expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

            select('Español', from: 'locale-switcher')

            expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
          end

          scenario "Highlight selected locale", :js do
            visit @edit_answer_url

            expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

            click_link "Español"

            expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
          end

          scenario "Show selected locale form", :js do
            visit @edit_answer_url

            expect(page).to have_field('poll_question_answer_title_en', with: 'Answer in English')

            click_link "Español"

            expect(page).to have_field('poll_question_answer_title_es', with: 'Respuesta en Español')
          end

          scenario "Select a locale and add it to the poll form", :js do
            visit @edit_answer_url

            select "Français", from: "translation_locale"

            expect(page).to have_link "Français"

            click_link "Français"

            expect(page).to have_field('poll_question_answer_title_fr')
          end
        end
      end
    end
  end
end
