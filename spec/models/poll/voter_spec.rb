require "rails_helper"

describe Poll::Voter do
  describe "validations" do
    let(:poll) { create(:poll) }
    let(:booth) { create(:poll_booth) }
    let(:booth_assignment) { create(:poll_booth_assignment, poll: poll, booth: booth) }
    let(:voter) { create(:poll_voter) }
    let(:user) { create(:user, :level_two) }

    it "is valid" do
      expect(voter).to be_valid
    end

    it "is not valid without a user" do
      voter.user = nil
      expect(voter).not_to be_valid
    end

    it "is not valid without a poll" do
      voter.poll = nil
      expect(voter).not_to be_valid
    end

    it "is valid if has not voted" do
      voter = build(:poll_voter, :valid_document)

      expect(voter).to be_valid
    end

    it "is not valid if the user has already voted in the same poll or booth_assignment" do
      create(:poll_voter, user: user, poll: poll)

      voter = build(:poll_voter, user: user, poll: poll)

      expect(voter).not_to be_valid
      expect(voter.errors.messages[:user_id]).to eq(["User has already voted"])
    end

    it "is not valid if the user has already voted in the same poll/booth" do
      create(:poll_voter, user: user, poll: poll, booth_assignment: booth_assignment)

      voter = build(:poll_voter, user: user, poll: poll, booth_assignment: booth_assignment)

      expect(voter).not_to be_valid
      expect(voter.errors.messages[:user_id]).to eq(["User has already voted"])
    end

    it "is not valid if the user has already voted in different booth in the same poll" do
      create(:poll_voter, :from_booth, user: user, poll: poll, booth: create(:poll_booth))

      voter = build(:poll_voter, :from_booth, user: user, poll: poll, booth: booth)

      expect(voter).not_to be_valid
      expect(voter.errors.messages[:user_id]).to eq(["User has already voted"])
    end

    it "is valid if the user has already voted in the same booth in different poll" do
      create(:poll_voter, :from_booth, user: user, booth: booth, poll: create(:poll))

      voter = build(:poll_voter, :from_booth, user: user, booth: booth, poll: poll)

      expect(voter).to be_valid
    end

    it "is not valid if the user has voted via web" do
      answer = create(:poll_answer)
      create(:poll_voter, :from_web, user: answer.author, poll: answer.poll)

      voter = build(:poll_voter, poll: answer.question.poll, user: answer.author)
      expect(voter).not_to be_valid
      expect(voter.errors.messages[:user_id]).to eq(["User has already voted"])
    end

    context "Skip verification is enabled" do
      before do
        Setting["feature.user.skip_verification"] = true
        user.update!(document_number: nil, document_type: nil)
      end

      it "is not valid if the user has already voted in the same poll" do
        create(:poll_voter, user: user, poll: poll)

        voter = build(:poll_voter, user: user, poll: poll)

        expect(voter).not_to be_valid
      end

      it "is valid if other users have voted in the same poll" do
        another_user = create(:user, :level_two, document_number: nil, document_type: nil)
        create(:poll_voter, user: another_user, poll: poll)

        voter = build(:poll_voter, user: user, poll: poll)

        expect(voter).to be_valid
      end
    end

    context "origin" do
      it "is not valid without an origin" do
        voter.origin = nil
        expect(voter).not_to be_valid
      end

      it "is not valid without a valid origin" do
        voter.origin = "invalid_origin"
        expect(voter).not_to be_valid
      end

      it "is valid with a booth origin" do
        voter.origin = "booth"
        voter.officer_assignment = create(:poll_officer_assignment)
        expect(voter).to be_valid
      end

      it "is valid with a web origin" do
        voter.origin = "web"
        expect(voter).to be_valid
      end
    end

    context "assignments" do
      it "is not valid without a booth_assignment_id when origin is booth" do
        voter.origin = "booth"
        voter.booth_assignment_id = nil
        expect(voter).not_to be_valid
      end

      it "is not valid without an officer_assignment_id when origin is booth" do
        voter.origin = "booth"
        voter.officer_assignment_id = nil
        expect(voter).not_to be_valid
      end

      it "is valid without assignments when origin is web" do
        voter.origin = "web"
        voter.booth_assignment_id = nil
        voter.officer_assignment_id = nil
        expect(voter).to be_valid
      end
    end
  end

  describe "scopes" do
    describe "#web" do
      it "returns voters with a web origin" do
        voter = create(:poll_voter, :from_web)

        expect(Poll::Voter.web).to eq [voter]
      end

      it "does not return voters with a booth origin" do
        create(:poll_voter, :from_booth)

        expect(Poll::Voter.web).to be_empty
      end
    end

    describe "#booth" do
      it "returns voters with a booth origin" do
        voter = create(:poll_voter, :from_booth)

        expect(Poll::Voter.booth).to eq [voter]
      end

      it "does not return voters with a web origin" do
        create(:poll_voter, :from_web)

        expect(Poll::Voter.booth).to be_empty
      end
    end
  end

  describe "save" do
    it "sets demographic info" do
      geozone = create(:geozone)
      user = create(:user, :level_two,
                    geozone: geozone,
                    date_of_birth: 30.years.ago,
                    gender: "female")

      voter = build(:poll_voter, user: user)
      voter.save!

      expect(voter.geozone).to eq(geozone)
      expect(voter.age).to eq(30)
      expect(voter.gender).to eq("female")
    end

    it "sets user info" do
      user = create(:user, document_number: "1234A", document_type: "1")
      voter = build(:poll_voter, user: user, token: "1234abcd")
      voter.save!

      expect(voter.document_number).to eq("1234A")
      expect(voter.document_type).to eq("1")
      expect(voter.token).to eq("1234abcd")
    end

    it "sets user info with skip verification enabled" do
      Setting["feature.user.skip_verification"] = true
      user = create(:user)
      voter = build(:poll_voter, user: user, token: "1234abcd")
      voter.save!

      expect(voter.token).to eq("1234abcd")
    end
  end
end
