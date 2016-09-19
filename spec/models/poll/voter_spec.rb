require 'rails_helper'

describe :voter do

  let(:poll) { create(:poll) }
  let(:booth) { create(:poll_booth, poll: poll) }

  describe "validations" do

    it "should be valid if in census and has not voted" do
       voter = build(:poll_voter, :valid_document, booth: booth)

       expect(voter).to be_valid
    end

    it "should not be valid if the user is not in the census" do
      voter = build(:poll_voter, :invalid_document, booth: booth)

      expect(voter).to_not be_valid
      expect(voter.errors.messages[:document_number]).to eq(["Document not in census"])
    end

    it "should not be valid if the user has already voted in the same booth" do
      voter1 = create(:poll_voter, :valid_document, booth: booth)
      voter2 =  build(:poll_voter, :valid_document, booth: booth)

      expect(voter2).to_not be_valid
      expect(voter2.errors.messages[:document_number]).to eq(["José García has already voted"])
    end

    it "should not be valid if the user has already voted in another booth" do
      booth1 = create(:poll_booth, poll: poll)
      booth2 = create(:poll_booth, poll: poll)

      voter1 = create(:poll_voter, :valid_document, booth: booth1)
      voter2 =  build(:poll_voter, :valid_document, booth: booth2)

      expect(voter2).to_not be_valid
      expect(voter2.errors.messages[:document_number]).to eq(["José García has already voted"])
    end

    xit "should not be valid if the user has voted via web" do
      pending "Implementation for voting via web"
    end

  end
end