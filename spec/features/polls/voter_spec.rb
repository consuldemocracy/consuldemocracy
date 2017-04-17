require 'rails_helper'

feature "Voter" do

  context "Origin" do

    scenario "Voting in web", :nvotes do
      user  = create(:user, :in_census, id: rand(9999999))
      poll = create(:poll)
      nvote = create(:poll_nvote, user: user, poll: poll)

      simulate_nvotes_callback(nvote, poll)

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("web")
    end

    scenario "Voting in booth", :js do
      user  = create(:user, :in_census)
      create(:geozone, :in_census)

      poll = create(:poll)
      officer = create(:poll_officer)

      ba = create(:poll_booth_assignment, poll: poll)
      create(:poll_officer_assignment, officer: officer, booth_assignment: ba)

      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content poll.name

      first(:button, "Confirm vote").click
      expect(page).to have_content "Vote introduced!"

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("booth")
    end

  end

end