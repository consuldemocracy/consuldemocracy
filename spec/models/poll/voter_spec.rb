require 'rails_helper'

describe :voter do

  let(:poll) { create(:poll) }
  let(:booth) { create(:poll_booth) }
  let(:booth_assignment) { create(:poll_booth_assignment, poll: poll, booth: booth) }
  let(:voter) { create(:poll_voter) }

  describe "validations" do

    it "should be valid" do
      expect(voter).to be_valid
    end

    it "should not be valid without a user" do
      voter.user = nil
      expect(voter).to_not be_valid
    end

    it "should not be valid without a poll" do
      voter.poll = nil
      expect(voter).to_not be_valid
    end

    it "should be valid if has not voted" do
       voter = build(:poll_voter, :valid_document)

       expect(voter).to be_valid
    end

    it "should not be valid if the user has already voted in the same poll or booth_assignment" do
      user = create(:user, :level_two)

      voter1 = create(:poll_voter, user: user, poll: poll)
      voter2 = build(:poll_voter, user: user, poll: poll)

      expect(voter2).to_not be_valid
      expect(voter2.errors.messages[:document_number]).to eq(["User has already voted"])
    end

    it "should not be valid if the user has already voted in the same poll/booth" do
      user = create(:user, :level_two)

      voter1 = create(:poll_voter, user: user, poll: poll, booth_assignment: booth_assignment)
      voter2 = build(:poll_voter, user: user, poll: poll, booth_assignment: booth_assignment)

      expect(voter2).to_not be_valid
      expect(voter2.errors.messages[:document_number]).to eq(["User has already voted"])
    end

    it "should not be valid if the user has already voted in different booth in the same poll" do
      booth_assignment1 = create(:poll_booth_assignment, poll: poll)
      booth_assignment2 = create(:poll_booth_assignment, poll: poll)

      user = create(:user, :level_two)

      voter1 = create(:poll_voter, user: user, poll: poll, booth_assignment: booth_assignment1)
      voter2 = build(:poll_voter, user: user, poll: poll, booth_assignment: booth_assignment2)

      expect(voter2).to_not be_valid
      expect(voter2.errors.messages[:document_number]).to eq(["User has already voted"])
    end

    it "should be valid if the user has already voted in the same booth in different poll" do
      booth_assignment1 = create(:poll_booth_assignment, booth: booth)
      booth_assignment2 = create(:poll_booth_assignment, booth: booth, poll: poll)

      user = create(:user, :level_two)

      voter1 = create(:poll_voter, user: user, booth_assignment: booth_assignment1)
      voter2 = build(:poll_voter, user: user, booth_assignment: booth_assignment2)

      expect(voter2).to be_valid
    end

    it "should not be valid if the user has voted via web" do
      answer = create(:poll_answer)
      answer.record_voter_participation('token')

      voter = build(:poll_voter, poll: answer.question.poll, user: answer.author)
      expect(voter).to_not be_valid
      expect(voter.errors.messages[:document_number]).to eq(["User has already voted"])
    end

    context "origin" do

      it "should not be valid without an origin" do
        voter.origin = nil
        expect(voter).to_not be_valid
      end

      it "should not be valid without a valid origin" do
        voter.origin = "invalid_origin"
        expect(voter).to_not be_valid
      end

      it "should be valid with a booth origin" do
        voter.origin = "booth"
        expect(voter).to be_valid
      end

      it "should be valid with a web origin" do
        voter.origin = "web"
        expect(voter).to be_valid
      end

    end

  end

  describe "scopes" do

    describe "#web" do
      it "returns voters with a web origin" do
        voter1 = create(:poll_voter, origin: "web")
        voter2 = create(:poll_voter, origin: "web")
        voter3 = create(:poll_voter, origin: "booth")

        web_voters = Poll::Voter.web

        expect(web_voters.count).to eq(2)
        expect(web_voters).to     include(voter1)
        expect(web_voters).to     include(voter2)
        expect(web_voters).to_not include(voter3)
      end
    end

    describe "#booth" do
      it "returns voters with a booth origin" do
        voter1 = create(:poll_voter, origin: "booth")
        voter2 = create(:poll_voter, origin: "booth")
        voter3 = create(:poll_voter, origin: "web")

        booth_voters = Poll::Voter.booth

        expect(booth_voters.count).to eq(2)
        expect(booth_voters).to     include(voter1)
        expect(booth_voters).to     include(voter2)
        expect(booth_voters).to_not include(voter3)
      end
    end

  end

  describe "save" do

    it "sets demographic info" do
      geozone = create(:geozone)
      user = create(:user,
                    geozone: geozone,
                    date_of_birth: 30.years.ago,
                    gender: "female")

      voter = build(:poll_voter, user: user)
      voter.save

      expect(voter.geozone).to eq(geozone)
      expect(voter.age).to eq(30)
      expect(voter.gender).to eq("female")
    end

    it "sets user info" do
      user = create(:user, document_number: "1234A", document_type: "1")
      voter = build(:poll_voter, user: user, token: "1234abcd")
      voter.save

      expect(voter.document_number).to eq("1234A")
      expect(voter.document_type).to eq("1")
      expect(voter.token).to eq("1234abcd")
    end
  end
end
