require 'rails_helper'

feature "Voter" do

  context "Origin" do

    scenario "Voting in web" do
      user  = create(:user, :in_census, id: rand(9999))
      poll = create(:poll)
      nvote = create(:poll_nvote, user: user, poll: poll)

      simulate_nvotes_callback(nvote, poll)

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("web")
    end

    scenario "Voting in booth", :js do
      user  = create(:user, :in_census)
      poll = create(:poll)
      officer = create(:poll_officer)

      login_as(officer.user)

      validate_officer
      visit new_officing_residence_path
      officing_verify_residence

      click_button "Confirm vote"
      expect(page).to have_content "Vote introduced!"

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("booth")
    end

  end

end