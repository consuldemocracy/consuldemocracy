require 'rails_helper'

feature 'Town Planning - Benches' do

  scenario "Vote benches" do
    user = create(:user, :level_two)
    login_as(user)

    bench1 = create(:bench)
    bench2 = create(:bench)

    visit processes_path
    click_link "Participa en la votación"

    choose "id_#{bench1.id}"
    click_button "Enviar voto"

    expect(page).to have_content "Tu voto ha sido recibido"
    expect(page).to have_content "Has votado el proyecto: #{bench1.name}"
  end

end
