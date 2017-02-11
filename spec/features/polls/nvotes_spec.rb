require 'rails_helper'

feature 'Nvotes', :focus do

  scenario "Voting", :selenium do
    user = create(:user, :verified, id: rand(9999))
    poll = create(:poll, published: true, nvotes_poll_id: 128)

    login_as(user)
    visit poll_path(poll)

    nvotes = find(".agoravoting-voting-booth-iframe")
    within_frame(nvotes) do
      expect(page).to have_content "¿Quieres que XYZ sea aprobado?"

      first(".opt.ng-binding").click

      click_button "Continuar"

      expect(page).to have_content "La opción que seleccionaste es: Sí"
      click_button "Enviar el voto"

      expect(page).to have_content "Voto emitido con éxito"
    end
  end

  scenario "Store voter (valid signature)" do
    user  = create(:user, :in_census, id: rand(9999))
    poll = create(:poll, :incoming, published: true, nvotes_poll_id: 128)
    nvote = create(:poll_nvote, user: user, poll: poll)
    nvote.update(voter_hash: "33333333")

    message = "33333333:AuthEvent:128:RegisterSuccessfulLogin:1486030800"
    signature = nvote.generate_hash(message)

    authorization_hash = "khmac:///sha-256;#{signature}/#{message}"

    page.driver.header 'Authorization', authorization_hash
    page.driver.header 'ACCEPT', "application/json"
    page.driver.post polls_nvotes_success_path

    expect(page.status_code).to eq(200)
    expect(Poll::Voter.count).to eq(1)
  end

  scenario "Store voter (invalid signature)" do
    user  = create(:user, :in_census, id: rand(9999))
    poll = create(:poll, :incoming, published: true, nvotes_poll_id: 128)
    nvote = create(:poll_nvote, user: user, poll: poll)
    nvote.update(voter_hash: "33333333")

    message = "33333333:AuthEvent:128:RegisterSuccessfulLogin:1486030800"
    signature = "wrong_signature"

    authorization_hash = "khmac:///sha-256;#{signature}/#{message}"

    page.driver.header 'Authorization', authorization_hash
    page.driver.header 'ACCEPT', "application/json"
    page.driver.post polls_nvotes_success_path

    expect(page.status_code).to eq(400)
    expect(Poll::Voter.count).to eq(0)
  end

end
