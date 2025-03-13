require "rails_helper"

describe "Voters" do
  let(:poll) { create(:poll) }
  let(:booth) { create(:poll_booth) }
  let(:officer) { create(:poll_officer) }

  before do
    create(:geozone, :in_census)
    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
    create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth)
    login_as(officer.user)
    set_officing_booth(booth)
  end

  scenario "Can vote" do
    create(:poll_officer_assignment, officer: officer)

    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content "Polls"
    expect(page).to have_content poll.name

    click_button "Confirm vote"

    expect(page).to have_content "Vote introduced!"
    expect(page).not_to have_button "Confirm vote"

    page.evaluate_script("window.location.reload()")
    expect(page).to have_content "Has already participated in this poll"
    expect(page).not_to have_button "Confirm vote"
  end

  scenario "Cannot vote" do
    unvotable_poll = create(:poll, geozone_restricted_to: [create(:geozone, census_code: "02")])
    create(:poll_officer_assignment, officer: officer, poll: unvotable_poll, booth: booth)

    set_officing_booth(booth)
    visit new_officing_residence_path
    officing_verify_residence

    within("#poll_#{unvotable_poll.id}") do
      expect(page).to have_content "The person cannot vote"
      expect(page).not_to have_button "Confirm vote"
    end
  end

  scenario "Already voted" do
    poll2 = create(:poll)
    create(:poll_officer_assignment, officer: officer, poll: poll2, booth: booth)

    user = create(:user, :level_two)
    voter = create(:poll_voter, poll: poll, user: user)

    visit new_officing_voter_path(id: voter.user.id)

    within("#poll_#{poll.id}") do
      expect(page).to have_content "Has already participated in this poll"
      expect(page).not_to have_button "Confirm vote"
    end

    within("#poll_#{poll2.id}") do
      expect(page).to have_button "Confirm vote"
    end
  end

  scenario "Had already verified his residence, but is not level 2 yet" do
    user = create(:user,
                  residence_verified_at: Time.current,
                  document_type: "1",
                  document_number: "12345678Z")
    expect(user).not_to be_level_two_verified

    logout
    login_through_form_as_officer(officer)

    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content "Polls"
    expect(page).to have_content poll.name
  end

  context "Polls displayed to officers" do
    scenario "Display current polls assigned to a booth" do
      poll = create(:poll)
      create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth)

      set_officing_booth(booth)
      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content "Polls"
      expect(page).to have_content poll.name
    end

    scenario "Display polls that the user can vote" do
      votable_poll = create(:poll, geozone_restricted_to: [Geozone.first])
      create(:poll_officer_assignment, officer: officer, poll: votable_poll, booth: booth)

      set_officing_booth(booth)
      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content "Polls"
      expect(page).to have_content votable_poll.name
    end

    scenario "Display polls that the user cannot vote" do
      unvotable_poll = create(:poll, geozone_restricted_to: [create(:geozone, census_code: "02")])
      create(:poll_officer_assignment, officer: officer, poll: unvotable_poll, booth: booth)

      set_officing_booth(booth)
      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content "Polls"
      expect(page).to have_content unvotable_poll.name
    end

    scenario "Do not display expired polls" do
      expired_poll = create(:poll, :expired)
      create(:poll_officer_assignment, officer: officer, poll: expired_poll, booth: booth)

      set_officing_booth(booth)
      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content "Polls"
      expect(page).not_to have_content expired_poll.name
    end

    scenario "Do not display polls from other booths" do
      poll1 = create(:poll)
      poll2 = create(:poll)

      booth1 = create(:poll_booth)
      booth2 = create(:poll_booth)

      create(:poll_officer_assignment, officer: officer, poll: poll1, booth: booth1)
      create(:poll_officer_assignment, officer: officer, poll: poll2, booth: booth2)

      set_officing_booth(booth1)
      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content "Polls"
      expect(page).to have_content poll1.name
      expect(page).not_to have_content poll2.name

      set_officing_booth(booth2)
      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content "Polls"
      expect(page).to have_content poll2.name
      expect(page).not_to have_content poll1.name
    end
  end
end
