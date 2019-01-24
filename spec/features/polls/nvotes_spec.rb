require 'rails_helper'

feature 'Nvotes' do

  before do
    skip "this feature is currently disabled"
  end

  scenario "Check correct configuration" do
    expect(Rails.application.secrets["nvotes_shared_key"]).not_to eq("")
    expect(Rails.application.secrets["nvotes_server_url"]).not_to eq("")
  end

  scenario "Send vote", :selenium do
    user = create(:user, :level_two, id: rand(9999999))
    poll = create(:poll, published: true, nvotes_poll_id: 128)
    officer = create(:poll_officer)

    booth_assignment = create(:poll_booth_assignment, poll: poll)
    officer_assignment = create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

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

    # Simulate callback
    create(:poll_voter, :valid_document, user: user, poll: poll)

    login_as(officer.user)

    set_officing_booth(officer_assignment.booth)
    visit new_officing_voter_path(id: user.id)

    within("#poll_#{poll.id}") do
      expect(page).to have_content "Has already participated in this poll"
      expect(page).not_to have_button "Confirm vote"
    end
  end

  context "Store voter" do

    scenario "Valid signature", :page_driver do
      user  = create(:user, :in_census, id: rand(9999999))
      poll = create(:poll, :incoming, published: true, nvotes_poll_id: 128)

      nvote = create(:poll_nvote, user: user, poll: poll)
      nvote.update(voter_hash: "33333333")

      message = "33333333:AuthEvent:128:RegisterSuccessfulLogin:1486030800"
      signature = Poll::Nvote.generate_hash(message)

      authorization_hash = "khmac:///sha-256;#{signature}/#{message}"

      page.driver.header 'Authorization', authorization_hash
      page.driver.header 'ACCEPT', "application/json"
      page.driver.post polls_nvotes_success_path

      expect(page.status_code).to eq(200)
      expect(Poll::Voter.count).to eq(1)
    end

    scenario "Invalid signature", :page_driver do
      user  = create(:user, :in_census, id: rand(9999999))
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

    scenario "Officer information", :page_driver do
      user  = create(:user, :in_census, id: rand(9999999))
      poll = create(:poll, :incoming, published: true, nvotes_poll_id: 128)

      booth_assignment = create(:poll_booth_assignment, poll: poll)
      officer_assignment = create(:poll_officer_assignment, booth_assignment: booth_assignment)

      nvote = create(:poll_nvote,
                     user: user,
                     poll: poll,
                     booth_assignment: booth_assignment,
                     officer_assignment: officer_assignment)
      nvote.update(voter_hash: "33333333")

      message = "33333333:AuthEvent:128:RegisterSuccessfulLogin:1486030800"
      signature = Poll::Nvote.generate_hash(message)

      authorization_hash = "khmac:///sha-256;#{signature}/#{message}"

      page.driver.header 'Authorization', authorization_hash
      page.driver.header 'ACCEPT', "application/json"
      page.driver.post polls_nvotes_success_path

      expect(page.status_code).to eq(200)
      expect(Poll::Voter.count).to eq(1)

      voter = Poll::Voter.first
      expect(voter.officer_assignment_id).to eq(nvote.officer_assignment_id)
      expect(voter.booth_assignment_id).to eq(nvote.booth_assignment_id)
    end
  end

end
