require "rails_helper"

describe Officing::VotersController do
  describe "POST create" do
    it "does not create two records with two simultaneous requests", :race_condition do
      officer = create(:poll_officer)
      poll = create(:poll, officers: [officer])
      user = create(:user, :level_two)

      sign_in(officer.user)

      2.times.map do
        Thread.new do
          post :create, params: {
            voter: { poll_id: poll.id, user_id: user.id },
            format: :js
          }
        rescue ActionDispatch::IllegalStateError, ActiveRecord::RecordInvalid
        end
      end.each(&:join)

      expect(Poll::Voter.count).to eq 1
      expect(Poll::Voter.last.officer_id).to eq(officer.id)
    end

    it "stores officer and booth information" do
      officer = create(:poll_officer)
      user = create(:user, :in_census)
      poll1 = create(:poll, name: "Would you be interested in XYZ?")
      poll2 = create(:poll, name: "Testing polls")

      booth = create(:poll_booth)

      assignment1 = create(:poll_booth_assignment, poll: poll1, booth: booth)
      assignment2 = create(:poll_booth_assignment, poll: poll2, booth: booth)
      create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)

      validate_officer
      set_officing_booth(booth)
      sign_in(officer.user)

      post :create, params: {
        voter: { poll_id: poll1.id, user_id: user.id },
        format: :js
      }
      expect(response).to be_successful

      post :create, params: {
        voter: { poll_id: poll2.id, user_id: user.id },
        format: :js
      }
      expect(response).to be_successful

      expect(Poll::Voter.count).to eq(2)

      voter1 = Poll::Voter.first
      expect(voter1.booth_assignment).to eq(assignment1)
      expect(voter1.officer_assignment).to eq(assignment1.officer_assignments.first)

      voter2 = Poll::Voter.last
      expect(voter2.booth_assignment).to eq(assignment2)
      expect(voter2.officer_assignment).to eq(assignment2.officer_assignments.first)
    end
  end
end
