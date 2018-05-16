require 'rails_helper'

describe Poll::Voter do

  let(:poll) { create(:poll) }
  let(:booth) { create(:poll_booth) }
  let(:booth_assignment) { create(:poll_booth_assignment, poll: poll, booth: booth) }
  let(:voter) { create(:poll_voter) }


  describe "save" do

    it "sets demographic info" do
      geozone = create(:geozone)
      user = create(:user,
                    geozone: geozone,
                    date_of_birth: 20.years.ago,
                    gender: "female")

      voter = build(:poll_voter, user: user)
      voter.save

      expect(voter.geozone).to eq(geozone)
      expect(voter.age).to eq(20)
      expect(voter.gender).to eq("female")
    end
  end
end
