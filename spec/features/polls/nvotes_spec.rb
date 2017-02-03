require 'rails_helper'

feature 'Nvotes' do

  scenario "Voting", :selenium do
    user = create(:user, :verified, id: rand(9999))
    poll = create(:poll, published: true, nvotes_poll_id: 128)

    login_as(user)
    visit poll_path(poll)

    click_link "Votar con Nvotes"

    nvotes = find(".agoravoting-voting-booth-iframe")
    within_frame(nvotes) do
      expect(page).to have_content "Votación de prueba"

      if page.has_button?("Empezar a votar")
        click_button "Empezar a votar"
      end

      expect(page).to have_content "¿Quieres que XYZ sea aprobado?"

      first(".opt.ng-binding").click

      click_button "Continuar"

      expect(page).to have_content "La opción que seleccionaste es: Sí"
      click_button "Enviar el voto"

      expect(page).to have_content "Enviando la papeleta cifrada al servidor"
      expect(page).to have_content "Voto emitido con éxito"
    end
  end

  scenario "Store voter" do
    user  = create(:user, :in_census, id: rand(9999))
    poll = create(:poll, :incoming, published: true, nvotes_poll_id: 128)
    nvote = create(:poll_nvote, user: user, poll: poll)
    nvote.update(voter_hash: "33333333")

    authorization_hash = "khmac:///sha-256;12345678/33333333:AuthEvent:128:RegisterSuccessfulLogin:1486030800"

    page.driver.header 'Authorization', authorization_hash
    page.driver.header 'ACCEPT', "application/json"
    page.driver.post polls_nvotes_success_path

    expect(Poll::Voter.count).to eq(1)
  end

end
