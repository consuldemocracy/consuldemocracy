require 'rails_helper'

feature 'Spain square' do

  scenario 'Fill out survey' do
    user = create(:user, :level_two)
    login_as(user)

    visit root_path
    click_link "Open processes"

    within "#spain-square" do
      click_link "More information"
    end

    click_link "Decides!"

    expect(page).to have_content "Remodeling of the Plaza de España"

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

    click_button "Enviar respuesta"

    expect(page).to have_content "¡Gracias por completar la encuesta!"
  end

end