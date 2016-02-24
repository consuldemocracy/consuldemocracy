require 'rails_helper'

feature 'Spain square' do

  context "Fill out survey" do

    scenario "by a verified user" do
      user = create(:user, :level_two)
      login_as(user)

      visit root_path
      click_link "Open processes"

      within "#spain-square" do
        click_link "More information"
      end

      click_link "Decides!"

      expect(page).to have_content "1a. ¿Crees necesario reformar la Plaza de España?"

      fill_in_survey
      click_button "Enviar respuesta"

      expect(page).to have_content "¡Gracias por completar las preguntas!"
    end

    scenario "by a level 1 user", :js do
      user = create(:user)
      login_as(user)

      visit "processes_plaza_espana"
      click_link "Decides!"
      expect(page).to have_content "1a. ¿Crees necesario reformar la Plaza de España?"
      choose('questions_1a_a')

      expect(page).to have_content "Solo los usuarios verificados pueden responder a la encuesta, verifica tu cuenta"

      click_link "verifica tu cuenta"
      expect(page).to have_content "Verify residence"
    end

    scenario "by a user not logged", :js do
      user = create(:user, sign_in_count: 2)

      visit "processes_plaza_espana"
      click_link "Decides!"

      expect(page).to have_content "1a. ¿Crees necesario reformar la Plaza de España?"

      choose('questions_1a_a')

      expect(page).to have_content "Solo los usuarios verificados pueden responder a la encuesta, necesitas iniciar sesión o registrarte para continuar."

      click_link "iniciar sesión"

      expect(page).to have_content "Sign in"

      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      click_button 'Enter'

      expect(page).to have_content "1a. ¿Crees necesario reformar la Plaza de España?"
    end

  end

  context "Open Answers" do

    context "Vote other user's answers" do

      background do
        @isabel    = create(:user, :level_two)
        @cervantes = create(:user, :level_two)
        @manuela   = create(:user, :level_two)

        login_as(@isabel)
        visit "encuesta-plaza-espana/"

        fill_in_survey
        click_button "Enviar respuesta"
        expect(page).to have_content "¡Gracias por completar las preguntas!"
      end

      scenario 'Show' do
        open_answer_16 = OpenAnswer.where(question_code: 16).first
        open_answer_17 = OpenAnswer.where(question_code: 17).first

        create(:vote, voter: @cervantes, votable: open_answer_16, vote_flag: true)
        create(:vote, voter: @manuela,   votable: open_answer_16, vote_flag: false)

        visit "/encuesta-plaza-espana/respuestas"

        within "#open_answer_#{open_answer_16.id}_votes" do
          within(".in_favor") do
            expect(page).to have_content "1"
          end

          within(".against") do
            expect(page).to have_content "1"
          end
        end
      end

      scenario 'Create', :js do
        within "#open_answer_#{OpenAnswer.last.id}_votes" do
          find(".in_favor a").click

          within(".in_favor") do
            expect(page).to have_content "1"
          end

          within(".against") do
            expect(page).to have_content "0"
          end
        end
      end

      scenario 'Update', :js do
        within "#open_answer_#{OpenAnswer.last.id}_votes" do
          find('.in_favor a').click
          find('.against a').click

          within('.in_favor') do
            expect(page).to have_content "0"
          end

          within('.against') do
            expect(page).to have_content "1"
          end
        end
      end

      scenario 'Trying to vote multiple times', :js do
        within "#open_answer_#{OpenAnswer.last.id}_votes" do
          find('.in_favor a').click
          find('.in_favor a').click

          within('.in_favor') do
            expect(page).to have_content "1"
          end

          within('.against') do
            expect(page).to have_content "0"
          end
        end
      end

    end

  end

end

def fill_in_survey
  choose('questions_1a_a')
  first('#questions_1b').set(true)
  first('#questions_2').set(true)
  first('#questions_3').set(true)
  first('#questions_4').set(true)
  choose('questions_5a_1')
  choose('questions_5b_1')
  choose('questions_5c_1')
  choose('questions_5d_1')
  choose('questions_5e_1')
  choose('questions_6_a')
  first('#questions_7').set(true)
  choose('questions_8a_a')
  choose('questions_8b_a')
  choose('questions_9_a')
  first('#questions_10').set(true)
  choose('questions_11_a')
  choose('questions_12a_a')
  choose('questions_12b_a')
  choose('questions_12c_a')
  choose('questions_13_a')
  first('#questions_14').set(true)
  choose('questions_15a_a')
  choose('questions_15bCaminando_1')
  choose('questions_15bEnBicicleta_2')
  choose('questions_15bEnCoche_3')
  choose('questions_15bEnTransportePublico_1')
  fill_in("questions_16", with: "I believe...")
  fill_in("questions_17", with: "In my opinion...")
  choose('questions_18_a')
end
