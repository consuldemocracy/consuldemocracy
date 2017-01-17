require 'rails_helper'

feature 'Volunteer Poll' do

  scenario "Create" do
    visit new_volunteer_poll_path
    fill_in 'volunteer_poll_email', with: "example@example.com"
    fill_in 'volunteer_poll_first_name', with: "Isabel"
    fill_in 'volunteer_poll_last_name', with: "Johnson"
    fill_in 'volunteer_poll_document_number', with: "12345678Z"
    fill_in 'volunteer_poll_phone', with: "606111111"
    select '2 turnos', from: 'volunteer_poll_turns'
    check_all_day_checkboxes
    check_all_geozones_checkboxes
    click_button "Enviar"

    expect(page).to have_content "¡Muchas gracias! Tu solicitud ha sido enviada."

    volunteer = VolunteerPoll.first
    expect(volunteer.email).to eq("example@example.com")
    expect(volunteer.first_name).to eq("Isabel")
    expect(volunteer.last_name).to eq("Johnson")
    expect(volunteer.document_number).to eq("12345678Z")
    expect(volunteer.phone).to eq("606111111")
    expect(volunteer.turns).to eq("2 turnos")
    expect_all_days(volunteer)
    expect_all_geozones(volunteer)
  end

end

def check_all_day_checkboxes
  check 'volunteer_poll_monday_13_morning'
  check 'volunteer_poll_monday_13_afternoon'
  check 'volunteer_poll_tuesday_14_morning'
  check 'volunteer_poll_tuesday_14_afternoon'
  check 'volunteer_poll_wednesday_15_morning'
  check 'volunteer_poll_wednesday_15_afternoon'
  check 'volunteer_poll_thursday_16_morning'
  check 'volunteer_poll_thursday_16_afternoon'
  check 'volunteer_poll_friday_17_morning'
  check 'volunteer_poll_friday_17_afternoon'
  check 'volunteer_poll_saturday_18_morning'
  check 'volunteer_poll_saturday_18_afternoon'
  check 'volunteer_poll_sunday_19_morning'
  check 'volunteer_poll_sunday_19_afternoon'
  check 'volunteer_poll_monday_20_morning'
end

def check_all_geozones_checkboxes
  check "volunteer_poll_any_district"
  check "volunteer_poll_arganzuela"
  check "volunteer_poll_barajas"
  check "volunteer_poll_carabanchel"
  check "volunteer_poll_centro"
  check "volunteer_poll_chamartin"
  check "volunteer_poll_chamberi"
  check "volunteer_poll_ciudad_lineal"
  check "volunteer_poll_fuencarral_el_pardo"
  check "volunteer_poll_hortaleza"
  check "volunteer_poll_latina"
  check "volunteer_poll_moncloa_aravaca"
  check "volunteer_poll_moratalaz"
  check "volunteer_poll_puente_de_vallecas"
  check "volunteer_poll_retiro"
  check "volunteer_poll_salamanca"
  check "volunteer_poll_san_blas_canillejas"
  check "volunteer_poll_tetuan"
  check "volunteer_poll_usera"
  check "volunteer_poll_vicalvaro"
  check "volunteer_poll_villa_de_vallecas"
  check "volunteer_poll_villaverde"
end

def expect_all_days(volunteer)
  expect(volunteer.monday_13_morning).to be
  expect(volunteer.monday_13_afternoon).to be
  expect(volunteer.tuesday_14_morning).to be
  expect(volunteer.tuesday_14_afternoon).to be
  expect(volunteer.wednesday_15_morning).to be
  expect(volunteer.wednesday_15_afternoon).to be
  expect(volunteer.thursday_16_morning).to be
  expect(volunteer.thursday_16_afternoon).to be
  expect(volunteer.friday_17_morning).to be
  expect(volunteer.friday_17_afternoon).to be
  expect(volunteer.saturday_18_morning).to be
  expect(volunteer.saturday_18_afternoon).to be
  expect(volunteer.sunday_19_morning).to be
  expect(volunteer.sunday_19_afternoon).to be
  expect(volunteer.monday_20_morning).to be
end

def expect_all_geozones(volunteer)
  expect(volunteer.any_district).to be
  expect(volunteer.arganzuela).to be
  expect(volunteer.barajas).to be
  expect(volunteer.carabanchel).to be
  expect(volunteer.centro).to be
  expect(volunteer.chamartin).to be
  expect(volunteer.chamberi).to be
  expect(volunteer.ciudad_lineal).to be
  expect(volunteer.fuencarral_el_pardo).to be
  expect(volunteer.hortaleza).to be
  expect(volunteer.latina).to be
  expect(volunteer.moncloa_aravaca).to be
  expect(volunteer.moratalaz).to be
  expect(volunteer.puente_de_vallecas).to be
  expect(volunteer.retiro).to be
  expect(volunteer.salamanca).to be
  expect(volunteer.san_blas_canillejas).to be
  expect(volunteer.tetuan).to be
  expect(volunteer.usera).to be
  expect(volunteer.vicalvaro).to be
  expect(volunteer.villa_de_vallecas).to be
  expect(volunteer.villaverde).to be
end