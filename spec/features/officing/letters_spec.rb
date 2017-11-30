require 'rails_helper'

feature 'Letters' do
  let(:officer) { create(:poll_officer, letter_officer: true) }
  let(:poll)    { create(:poll) }

  background do
    login_as(officer.user)
    visit new_officing_letter_path

    allow_any_instance_of(Officing::Residence).
    to receive(:letter_poll).and_return(poll)
  end

  scenario "Verify and store voter" do
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'

    expect(page).to have_content 'Voto VÁLIDO'
    expect(page).to have_content '12345678Z'
    expect(page).to have_content '28013'

    voters = Poll::Voter.all
    expect(voters.count).to eq(1)
    expect(voters.first.origin).to eq("letter")
    expect(voters.first.document_number).to eq("12345678Z")
    expect(voters.first.document_type).to eq("1")
    expect(voters.first.poll).to eq(poll)

    logs = Poll::LetterOfficerLog.all
    expect(logs.count).to eq(1)
    expect(logs.first.user_id).to eq(officer.user_id)
    expect(logs.first.document_number).to eq("12345678Z")
    expect(logs.first.postal_code).to eq("28013")
    expect(logs.first.message).to eq("Voto VÁLIDO")
  end

  scenario "Error on verify (everything blank)" do
    click_button 'Validate document'

    expect(page).to have_content 'Voto NO VÁLIDO'
    expect(Poll::Voter.count).to eq(0)

    logs = Poll::LetterOfficerLog.all
    expect(logs.count).to eq(3)
    expect(logs.first.user_id).to eq(officer.user_id)
    expect(logs.first.document_number).to eq("")
    expect(logs.first.postal_code).to eq("")
    expect(logs.first.message).to eq("Voto NO VÁLIDO")
  end

  scenario "Error on Census (document number)" do
    initial_failed_census_calls_count = officer.failed_census_calls_count
    visit new_officing_letter_path

    fill_in 'residence_document_number', with: "9999999A"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'

    expect(page).to have_content 'Voto NO VÁLIDO'
    expect(page).to have_content '9999999A'
    expect(page).to have_content '28013'

    officer.reload
    fcc = FailedCensusCall.last
    expect(fcc).to be
    expect(fcc.poll_officer).to eq(officer)
    expect(officer.failed_census_calls.last).to eq(fcc)
    expect(officer.failed_census_calls_count).to eq(initial_failed_census_calls_count + 3)
  end

  scenario "Error on Census (postal code)" do
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28014'

    click_button 'Validate document'

    expect(page).to have_content 'Voto NO VÁLIDO'
    expect(page).to have_content '12345678Z'
    expect(page).to have_content '28014'

    logs = Poll::LetterOfficerLog.all
    expect(logs.count).to eq(3)
    expect(logs.first.user_id).to eq(officer.user_id)
    expect(logs.first.document_number).to eq("12345678Z")
    expect(logs.first.postal_code).to eq("28014")
    expect(logs.first.message).to eq("Voto NO VÁLIDO")
  end

  scenario "Error already voted" do
    poll = create(:poll)
    user = create(:user, document_number: "12345678Z")
    create(:poll_voter, user: user, poll: poll)

    allow_any_instance_of(Officing::Residence).
    to receive(:letter_poll).and_return(poll)

    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'

    expect(page).to have_content 'Voto REFORMULADO'
    expect(page).to have_content '12345678Z'
    expect(page).to have_content '28013'

    expect(Poll::Voter.count).to eq(1)

    logs = Poll::LetterOfficerLog.all
    expect(logs.count).to eq(1)
    expect(logs.first.reload.user_id).to eq(officer.user_id)
    expect(logs.first.document_number).to eq("12345678Z")
    expect(logs.first.postal_code).to eq("28013")
    expect(logs.first.message).to eq("Voto REFORMULADO")
  end

  scenario "Error underage" do
    poll = create(:poll)
    user = create(:user, document_number: "12345678Z")
    create(:poll_voter, user: user, poll: poll)

    allow_any_instance_of(Officing::Residence).
    to receive(:letter_poll).and_return(poll)

    allow_any_instance_of(Officing::Residence).
    to receive(:date_of_birth).and_return(13.years.ago)

    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'

    expect(page).to have_content 'Voto NO VÁLIDO'
    expect(page).to have_content '12345678Z'
    expect(page).to have_content '28013'

    expect(Poll::Voter.count).to eq(1)

    logs = Poll::LetterOfficerLog.all
    expect(logs.count).to eq(3)
    expect(logs.first.reload.user_id).to eq(officer.user_id)
    expect(logs.first.document_number).to eq("12345678Z")
    expect(logs.first.postal_code).to eq("28013")
    expect(logs.first.message).to eq("Voto NO VÁLIDO")
  end

  scenario "Validate next letter" do
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'
    expect(page).to have_content 'Voto VÁLIDO'

    click_link "Introducir nuevo documento"
    expect(page).to have_content "Validate document"
  end

  context "Permissions" do

    scenario "Non officers can not access letter interface" do
      user = create(:user)

      login_as(user)
      visit new_officing_letter_path

      expect(page).to have_content "You do not have permission to access this page"
    end

    scenario "Standard officers can not access letter interface" do
      officer = create(:poll_officer)

      login_as(officer.user)
      visit new_officing_letter_path

      expect(page).to have_content "You do not have permission to access this page"
    end

    scenario "Letter officers can access letter interface" do
      officer = create(:poll_officer, letter_officer: true)

      login_as(officer.user)
      visit new_officing_letter_path

      expect(page).to have_content 'Validate document'
    end

    scenario "Admins can access letter interface" do
      admin = create(:administrator)

      login_as(admin.user)
      visit new_officing_letter_path

      expect(page).to have_content 'Validate document'
    end

  end

  #pending check to see if current_user is officer and has an active assignment
  xscenario "Sign in" do
    click_link 'Sign out'
    login_through_form_as(officer.user)

    expect(page).to have_current_path(new_officing_letter_path)
  end

  scenario "Going back after getting lost" do
    skip "this feature is disabled and this test goal is not well defined"

    visit root_path
    click_link "Polling officers"

    expect(page).to have_current_path(new_officing_letter_path)
  end

  context "Checks all document types" do

    scenario "Passport" do
      fill_in 'residence_document_number', with: "12345678A"
      fill_in 'residence_postal_code', with: '28013'

      click_button 'Validate document'

      expect(page).to have_content 'Voto VÁLIDO'
      expect(page).to have_content '12345678A'
      expect(page).to have_content '28013'

      voters = Poll::Voter.all
      expect(voters.count).to eq(1)
      expect(voters.first.origin).to eq("letter")
      expect(voters.first.document_number).to eq("12345678A")
      expect(voters.first.document_type).to eq("2")
      expect(voters.first.poll).to eq(poll)

      logs = Poll::LetterOfficerLog.all
      expect(logs.count).to eq(2)
      expect(logs.first.user_id).to eq(officer.user_id)
      expect(logs.first.document_number).to eq("12345678A")
      expect(logs.first.postal_code).to eq("28013")
      expect(logs.first.message).to eq("Voto NO VÁLIDO")

      expect(logs.last.user_id).to eq(officer.user_id)
      expect(logs.last.document_number).to eq("12345678A")
      expect(logs.last.postal_code).to eq("28013")
      expect(logs.last.message).to eq("Voto VÁLIDO")
    end

    scenario "Foreign resident" do
      fill_in 'residence_document_number', with: "12345678B"
      fill_in 'residence_postal_code', with: '28013'

      click_button 'Validate document'

      expect(page).to have_content 'Voto VÁLIDO'
      expect(page).to have_content '12345678B'
      expect(page).to have_content '28013'

      voters = Poll::Voter.all
      expect(voters.count).to eq(1)
      expect(voters.first.origin).to eq("letter")
      expect(voters.first.document_number).to eq("12345678B")
      expect(voters.first.document_type).to eq("3")
      expect(voters.first.poll).to eq(poll)

      logs = Poll::LetterOfficerLog.all
      expect(logs.count).to eq(3)
    end
  end

  context "No postal code" do

    scenario "Correct name" do
      fill_in 'residence_document_number', with: "12345678Z"

      click_button 'Validate document'

      expect(page).to have_content 'Verifica EL NOMBRE'
      expect(page).to have_content '12345678Z'
      expect(page).to have_content 'José García'

      voters = Poll::Voter.all
      expect(voters.count).to eq(0)

      logs = Poll::LetterOfficerLog.all
      expect(logs.count).to eq(1)
      expect(logs.first.document_number).to eq("12345678Z")
      expect(logs.first.postal_code).to eq("")
      expect(logs.first.census_postal_code).to eq("28013")
      expect(logs.first.message).to eq("Verifica EL NOMBRE")

      click_button "Nombre igual"

      expect(page).to have_content 'Voto VÁLIDO'
      expect(page).to have_content '12345678Z'
      expect(page).to have_content '28013'
    end

    scenario "Incorrect name" do
      fill_in 'residence_document_number', with: "12345678Z"

      click_button 'Validate document'

      expect(page).to have_content 'Verifica EL NOMBRE'
      expect(page).to have_content '12345678Z'
      expect(page).to have_content 'José García'

      voters = Poll::Voter.all
      expect(voters.count).to eq(0)

      logs = Poll::LetterOfficerLog.all
      expect(logs.count).to eq(1)
      expect(logs.first.document_number).to eq("12345678Z")
      expect(logs.first.postal_code).to eq("")
      expect(logs.first.census_postal_code).to eq("28013")
      expect(logs.first.message).to eq("Verifica EL NOMBRE")

      click_button "Nombre distinto"

      expect(page).to have_content 'Voto NO VÁLIDO'
      expect(page).to have_content '12345678Z'
      expect(page).to have_content 'Nombre: Incorrecto'
    end

    scenario "Already voted" do
      poll = create(:poll)
      user = create(:user, document_number: "12345678Z")
      create(:poll_voter, user: user, poll: poll)

      allow_any_instance_of(Officing::Residence).
      to receive(:letter_poll).and_return(poll)

      fill_in 'residence_document_number', with: "12345678Z"

      click_button 'Validate document'

      expect(page).to have_content 'Voto REFORMULADO'
      expect(page).to have_content '12345678Z'

      expect(Poll::Voter.count).to eq(1)

      logs = Poll::LetterOfficerLog.all
      expect(logs.count).to eq(1)
      expect(logs.first.reload.user_id).to eq(officer.user_id)
      expect(logs.first.document_number).to eq("12345678Z")
      expect(logs.first.postal_code).to eq("")
      expect(logs.first.message).to eq("Voto REFORMULADO")
    end

    scenario "Document number not in Census" do
      visit new_officing_letter_path

      fill_in 'residence_document_number', with: "9999999A"

      click_button 'Validate document'

      expect(page).to have_content 'Voto NO VÁLIDO'
      expect(page).to have_content '9999999A'
    end

  end
end
