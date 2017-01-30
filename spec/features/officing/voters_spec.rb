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
    poll = create(:poll)

    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content "Polls"
    expect(page).to have_content poll.name

    click_button "Validate vote"

    expect(page).to have_content "Vote validated successfully"
    expect(page).to_not have_button "Validate vote"

    page.evaluate_script("window.location.reload()")
    expect(page).to have_content "Has already participated in this poll"
    expect(page).to_not have_button "Validate vote"
  end

  scenario "Already voted", :js do
    poll1 = create(:poll)
    poll2 = create(:poll)

    user = create(:user, :level_two)
    voter = create(:poll_voter, poll: poll1, user: user)

    visit new_officing_voter_path(id: voter.user.id)

    within("#poll_#{poll1.id}") do
      expect(page).to have_content "Has already participated in this poll"
      expect(page).to_not have_button "Validate vote"
    end

    within("#poll_#{poll2.id}") do
      expect(page).to have_button "Validate vote"
    end
  end

  #Fix and use answerable_by(user)
  xscenario "Display only answerable polls"
end