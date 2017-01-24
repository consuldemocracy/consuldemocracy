require 'rails_helper'

feature 'Nvotes' do

  scenario "Voting", :selenium do
    user = create(:user, :verified, id: rand(9999))
    poll = create(:poll, published: true)

    login_as(user)
    visit poll_path(poll)

    click_link "Votar con Nvotes"

    nvotes = find(".agoravoting-voting-booth-iframe")
    within_frame(nvotes) do
      expect(page).to have_content "Votación de prueba"

      click_button "Empezar a votar"

      expect(page).to have_content "¿Quieres que XYZ sea aprobado?"

      first(".opt.ng-binding").click
      click_button "Continuar"

      expect(page).to have_content "La opción que seleccionaste es: Sí"
      click_button "Enviar el voto"

      expect(page).to have_content "Enviando la papeleta cifrada al servidor"
      expect(page).to have_content "Voto emitido con éxito"
    end
  end

end
