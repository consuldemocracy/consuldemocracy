require 'rails_helper'

feature 'Letters' do
  let(:officer) { create(:poll_officer) }
  let(:poll)    { create(:poll) }

  background do
    login_as(officer.user)
    visit new_officing_letter_path

    allow_any_instance_of(Officing::Residence).
    to receive(:letter_poll).and_return(poll)
  end

  scenario "Verify and store voter" do
    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'

    expect(page).to have_content 'voto VÁLIDO'
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
    expect(logs.first.message).to eq("voto VÁLIDO")
  end

  scenario "Error on verify (everything blank)" do
    click_button 'Validate document'

    expect(page).to have_content 'voto NO VÁLIDO'
    expect(Poll::Voter.count).to eq(0)

    logs = Poll::LetterOfficerLog.all
    expect(logs.count).to eq(1)
    expect(logs.first.user_id).to eq(officer.user_id)
    expect(logs.first.document_number).to eq("")
    expect(logs.first.postal_code).to eq("")
    expect(logs.first.message).to eq("voto NO VÁLIDO")
  end

  scenario "Error on Census (document number)" do
    initial_failed_census_calls_count = officer.failed_census_calls_count
    visit new_officing_letter_path

    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "9999999A"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'

    expect(page).to have_content 'voto NO VÁLIDO'
    expect(page).to have_content '9999999A'
    expect(page).to have_content '28013'

    officer.reload
    fcc = FailedCensusCall.last
    expect(fcc).to be
    expect(fcc.poll_officer).to eq(officer)
    expect(officer.failed_census_calls.last).to eq(fcc)
    expect(officer.failed_census_calls_count).to eq(initial_failed_census_calls_count + 1)
  end

  scenario "Error on Census (postal code)" do
    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28014'

    click_button 'Validate document'

    expect(page).to have_content 'voto NO VÁLIDO'
    expect(page).to have_content '12345678Z'
    expect(page).to have_content '28014'

    logs = Poll::LetterOfficerLog.all
    expect(logs.count).to eq(1)
    expect(logs.first.user_id).to eq(officer.user_id)
    expect(logs.first.document_number).to eq("12345678Z")
    expect(logs.first.postal_code).to eq("28014")
    expect(logs.first.message).to eq("voto NO VÁLIDO")
  end

  scenario "Error already voted" do
    poll = create(:poll)
    user = create(:user, document_number: "12345678Z")
    create(:poll_voter, user: user, poll: poll)

    allow_any_instance_of(Officing::Residence).
    to receive(:letter_poll).and_return(poll)

    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'

    expect(page).to have_content 'voto REFORMULADO'
    expect(page).to have_content '12345678Z'
    expect(page).to have_content '28013'

    expect(Poll::Voter.count).to eq(1)

    logs = Poll::LetterOfficerLog.all
    expect(logs.count).to eq(1)
    expect(logs.first.reload.user_id).to eq(officer.user_id)
    expect(logs.first.document_number).to eq("12345678Z")
    expect(logs.first.postal_code).to eq("28013")
    expect(logs.first.message).to eq("voto REFORMULADO")
  end

  scenario "Validate next letter" do
    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'
    expect(page).to have_content 'voto VÁLIDO'

    click_link "Introducir nuevo documento"
    expect(page).to have_content "Validate document"
  end

end