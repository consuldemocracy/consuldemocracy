require 'rails_helper'

describe Poll::BallotSheet do

  let(:ballot_sheet) { build(:poll_ballot_sheet, poll: create(:poll),
                             officer_assignment: create(:poll_officer_assignment),
                             data: "1234;5678") }

  context "Validations" do

    it "is valid" do
      expect(ballot_sheet).to be_valid
    end

    it "is not valid without a poll" do
      ballot_sheet.poll = nil
      expect(ballot_sheet).not_to be_valid
    end

    it "is not valid without an officer assignment" do
      ballot_sheet.officer_assignment = nil
      expect(ballot_sheet).not_to be_valid
    end

    it "is not valid without data" do
      ballot_sheet.data = nil
      expect(ballot_sheet).not_to be_valid
    end

  end

  context "#author" do

    it "returns the officer's name" do
      expect(ballot_sheet.author).to be(ballot_sheet.officer_assignment.officer.user.name)
    end

  end

end
