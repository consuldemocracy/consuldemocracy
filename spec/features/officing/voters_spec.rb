require 'rails_helper'

feature 'Voters' do

  let(:officer) { create(:poll_officer) }

  background do
    login_as(officer.user)
    create(:geozone, :in_census)

    #remove once foundation.equalizer js error has been fixed
    Capybara.current_driver = :poltergeist_no_js_errors
  end

  scenario "Can vote", :js do
    officer_assignment = create(:poll_officer_assignment, officer: officer)
    poll = officer_assignment.booth_assignment.poll

    set_officing_booth(officer_assignment.booth)
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
  end

  scenario "After voting, via nvotes or physical booth", :js do
    poll1 = create(:poll, geozone_restricted: false)
    poll2 = create(:poll, geozone_restricted: false)

    user = create(:user, :level_two)
    # We can not simulate the nvotes callback in selenium, so this covers
    # voting via officing - physical and tablet
    voter = create(:poll_voter, poll: poll1, user: user)

    use_physical_booth
    visit new_officing_voter_path(id: voter.user.id)

    within("#poll_#{poll1.id}") do
      expect(page).to have_content "Has already participated in this poll"
      expect(page).to_not have_button "Confirm vote"
    end

    within("#poll_#{poll2.id}") do
      expect(page).to have_button "Confirm vote"
    end

    login_as(user)
    visit poll_path(poll1)
    expect(page).to have_content "You already have participated in this poll."
    visit poll_path(poll2)
    expect(page).to_not have_content "You already have participated in this poll."
  end

  scenario "Store officer and booth information", :js do
    user  = create(:user, :in_census, id: rand(9999))
    poll1 = create(:poll, nvotes_poll_id: 128, name: "¿Quieres que XYZ sea aprobado?")
    poll2 = create(:poll, nvotes_poll_id: 136, name: "Pregunta de votación de prueba")

    booth = create(:poll_booth)

    ba1 = create(:poll_booth_assignment, poll: poll1, booth: booth )
    ba2 = create(:poll_booth_assignment, poll: poll2, booth: booth )
    oa1 = create(:poll_officer_assignment, officer: officer, booth_assignment: ba1, date: Date.current)
    oa2 = create(:poll_officer_assignment, officer: officer, booth_assignment: ba2, date: Date.current)

    set_officing_booth(booth)

    validate_officer
    visit new_officing_residence_path
    officing_verify_residence

    within("#poll_#{poll1.id}") do
      click_button "Confirm vote"

     expect(page).to have_content "Vote introduced!"
    end

    within("#poll_#{poll2.id}") do
      click_button "Confirm vote"

     expect(page).to have_content "Vote introduced!"
    end

    expect(Poll::Voter.count).to eq(2)

    voter1 = Poll::Voter.first

    expect(voter1.booth_assignment).to eq(ba1)
    expect(voter1.officer_assignment).to eq(oa1)

    voter2 = Poll::Voter.last
    expect(voter2.booth_assignment).to eq(ba2)
    expect(voter2.officer_assignment).to eq(oa2)
  end

  context "Booth type" do

    scenario "Physical booth", :js do
      poll = create(:poll)
      booth = create(:poll_booth, physical: true)

      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      officer_assignment = create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to     have_button "Confirm vote"
      expect(page).to_not have_link "Vote on tablet"
    end

    scenario "Digital booth", :js do
      poll = create(:poll)
      booth = create(:poll_booth, physical: false)

      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      officer_assignment = create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to_not have_button "Confirm vote"
      expect(page).to     have_link "Vote on tablet"
    end

  end

  xscenario "Display only answerable polls"
end
