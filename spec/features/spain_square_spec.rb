require 'rails_helper'

xfeature 'Spain square' do

  context "Fill out survey" do

    scenario "by a verified user" do
      user = create(:user, :level_two)
      login_as(user)

      visit root_path
      first(:link, "Open processes").click

      within "#spain-square" do
        click_link "More information"
      end

      click_link "Decides!"

      expect(page).to have_content "1a. ¿Crees necesario reformar la Plaza de España?"

      fill_in_survey
      click_button "Enviar respuesta"

      expect(page).to have_content "¡Gracias por completar las preguntas!"

      verify_answers(SurveyAnswer.last.answers)
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
  within("#q1b_container") do
    check "a) Plaza de los Cubos"
    check "c) Plaza de Emilio Jimenez Millás"
  end
  within("#q2_container") do
    check "a) Plaza de Oriente"
    check "b) Barrio de Conde Duque"
  end
  within("#q3_container") do
    check "a) Comercial"
    check "b) Hoteles"
    check "d) Terrazas"
    check "e) Mercadillos"
  end
  within("#q4_container") do
    check "c) Aparcamientos"
    check "d) Comercial"
  end
  choose('questions_5a_1')
  choose('questions_5b_1')
  choose('questions_5c_1')
  choose('questions_5d_1')
  choose('questions_5e_1')
  choose('questions_6_a')
  within("#q7_container") do
    check "b) Usos recreativos"
    check "e) No sabe"
  end
  choose('questions_8a_a')
  choose('questions_8b_a')
  choose('questions_9_a')
  within("#q10_container") do
    check "e) Crear un carril bici"
    check "g) Ninguna actuación respecto al tráfico"
  end
  choose('questions_11_a')
  choose('questions_12a_a')
  choose('questions_12b_a')
  choose('questions_12c_a')
  choose('questions_13_a')
  within("#q14_container") do
    check "d) Empleo de materiales reciclados"
    check "i) Todas las posibles"
  end
  fill_in("questions_14j", with: "Solar power")
  choose('questions_15a_a')
  choose('questions_15bCaminando_1')
  choose('questions_15bEnBicicleta_2')
  choose('questions_15bEnCoche_3')
  choose('questions_15bEnTransportePublico_1')
  fill_in("questions_16", with: "I believe...")
  fill_in("questions_17", with: "In my opinion...")
  choose('questions_18_a')
end

def verify_answers(answers)
  expect(answers["1a"]).to eq("a")
  expect(answers["1b"]).to eq(["a", "c"])
  expect(answers["2"]).to eq(["a", "b"])
  expect(answers["3"]).to eq(["a", "b", "d", "e"])
  expect(answers["3g"]).to eq("")
  expect(answers["4"]).to eq(["c", "d"])
  expect(answers["4l"]).to eq("")
  expect(answers["5a"]).to eq("1")
  expect(answers["5b"]).to eq("1")
  expect(answers["5c"]).to eq("1")
  expect(answers["5d"]).to eq("1")
  expect(answers["5e"]).to eq("1")
  expect(answers["6"]).to eq("a")
  expect(answers["7"]).to eq(["b", "e"])
  expect(answers["7d"]).to eq("")
  expect(answers["8a"]).to eq("a")
  expect(answers["8b"]).to eq("a")
  expect(answers["9"]).to eq("a")
  expect(answers["9e"]).to eq("")
  expect(answers["10"]).to eq(["e", "g"])
  expect(answers["10h"]).to eq("")
  expect(answers["11"]).to eq("a")
  expect(answers["11e"]).to eq("")
  expect(answers["12a"]).to eq("a")
  expect(answers["12b"]).to eq("a")
  expect(answers["12c"]).to eq("a")
  expect(answers["13"]).to eq("a")
  expect(answers["14"]).to eq(["d", "i"])
  expect(answers["14j"]).to eq("Solar power")
  expect(answers["15a"]).to eq("a")
  expect(answers["15bCaminando"]).to eq("1")
  expect(answers["15bEnBicicleta"]).to eq("2")
  expect(answers["15bEnCoche"]).to eq("3")
  expect(answers["15bEnTransportePublico"]).to eq("1")
  expect(answers["15bOtrosEspecificar"]).to eq("")
  expect(answers["16"]).to eq("I believe...")
  expect(answers["17"]).to eq("In my opinion...")
  expect(answers["18"]).to eq("a")
end


