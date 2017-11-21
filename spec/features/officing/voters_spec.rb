require 'rails_helper'

feature 'Voters' do

  let(:poll) { create(:poll, :current) }
  let(:booth) { create(:poll_booth) }
  let(:officer) { create(:poll_officer) }

  background do
    login_as(officer.user)
    create(:geozone, :in_census)
    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
    booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)
  end

  scenario "Can vote", :js do
    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content "Polls"
    expect(page).to have_content poll.name

    click_button "Confirm vote"

    expect(page).to have_content "Vote introduced!"
    expect(page).to_not have_button "Confirm vote"

    page.evaluate_script("window.location.reload()")
    expect(page).to have_content "Has already participated in this poll"
    expect(page).to_not have_button "Confirm vote"

    expect(Poll::Voter.last.officer_id).to eq(officer.id)
  end

  scenario "Already voted", :js do
    poll2 = create(:poll, :current)
    booth_assignment = create(:poll_booth_assignment, poll: poll2, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

    user = create(:user, :level_two)
    voter = create(:poll_voter, poll: poll, user: user)

    visit new_officing_voter_path(id: voter.user.id)

    within("#poll_#{poll.id}") do
      expect(page).to have_content "Has already participated in this poll"
      expect(page).to_not have_button "Confirm vote"
    end

    within("#poll_#{poll2.id}") do
      expect(page).to have_button "Confirm vote"
    end
  end

  scenario "Had already verified his residence, but is not level 2 yet", :js do
    user = create(:user, residence_verified_at: Time.current, document_type: "1", document_number: "12345678Z")
    expect(user).to_not be_level_two_verified

    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content "Polls"
    expect(page).to have_content poll.name
  end

  scenario "Display only current polls on which officer has a voting shift today, and user can answer", :js do
    poll_current = create(:poll, :current)
    second_booth = create(:poll_booth)
    booth_assignment = create(:poll_booth_assignment, poll: poll_current, booth: second_booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)
    create(:poll_shift, officer: officer, booth: second_booth, date: Date.current, task: :recount_scrutiny)
    create(:poll_shift, officer: officer, booth: second_booth, date: Date.tomorrow, task: :vote_collection)

    poll_expired = create(:poll, :expired)
    create(:poll_officer_assignment, officer: officer, booth_assignment: create(:poll_booth_assignment, poll: poll_expired, booth: booth))

    poll_incoming = create(:poll, :incoming)
    create(:poll_officer_assignment, officer: officer, booth_assignment: create(:poll_booth_assignment, poll: poll_incoming, booth: booth))

    poll_geozone_restricted_in = create(:poll, :current, geozone_restricted: true, geozones: [Geozone.first])
    booth_assignment = create(:poll_booth_assignment, poll: poll_geozone_restricted_in, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

    poll_geozone_restricted_out = create(:poll, :current, geozone_restricted: true, geozones: [create(:geozone, census_code: "02")])
    booth_assignment = create(:poll_booth_assignment, poll: poll_geozone_restricted_out, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content "Polls"
    expect(page).to have_content poll.name
    expect(page).not_to have_content poll_current.name
    expect(page).not_to have_content poll_expired.name
    expect(page).not_to have_content poll_incoming.name
    expect(page).to have_content poll_geozone_restricted_in.name
    expect(page).not_to have_content poll_geozone_restricted_out.name
  end
end
