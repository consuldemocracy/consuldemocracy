require 'rails_helper'

describe :voter do

  let(:poll) { create(:poll) }
  let(:booth) { create(:poll_booth) }
  let(:booth_assignment) { create(:poll_booth_assignment, poll: poll, booth: booth) }

  describe "validations" do

    it "should be valid if in census and has not voted" do
       voter = build(:poll_voter, :valid_document, booth_assignment: booth_assignment)

       expect(voter).to be_valid
    end

    it "should not be valid if the user is not in the census" do
      voter = build(:poll_voter, :invalid_document, booth_assignment: booth_assignment)

      expect(voter).to_not be_valid
      expect(voter.errors.messages[:document_number]).to eq(["Document not in census"])
    end

    it "should not be valid if the user has already voted in the same booth/poll" do
      voter1 = create(:poll_voter, :valid_document, booth_assignment: booth_assignment)
      voter2 =  build(:poll_voter, :valid_document, booth_assignment: booth_assignment)

      expect(voter2).to_not be_valid
      expect(voter2.errors.messages[:document_number]).to eq(["José García has already voted"])
    end

    it "should not be valid if the user has already voted in different booth in the same poll" do
      booth_assignment1 = create(:poll_booth_assignment, poll: poll)
      booth_assignment2 = create(:poll_booth_assignment, poll: poll)

      voter1 = create(:poll_voter, :valid_document, booth_assignment: booth_assignment1)
      voter2 =  build(:poll_voter, :valid_document, booth_assignment: booth_assignment2)

      expect(voter2).to_not be_valid
      expect(voter2.errors.messages[:document_number]).to eq(["José García has already voted"])
    end

    it "should be valid if the user has already voted in the same booth in different poll" do
      booth_assignment1 = create(:poll_booth_assignment, booth: booth)
      booth_assignment2 = create(:poll_booth_assignment, booth: booth, poll: poll)

      voter1 = create(:poll_voter, :valid_document, booth_assignment: booth_assignment1)
      voter2 =  build(:poll_voter, :valid_document, booth_assignment: booth_assignment2)

      expect(voter2).to be_valid
    end

    xit "should not be valid if the user has voted via web" do
      pending "Implementation for voting via web"
    end

  end
end