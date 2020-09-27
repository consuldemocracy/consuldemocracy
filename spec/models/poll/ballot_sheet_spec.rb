require "rails_helper"

describe Poll::BallotSheet do
  let(:ballot_sheet) do
    build(:poll_ballot_sheet, poll: create(:poll),
          officer_assignment: create(:poll_officer_assignment),
          data: "1234;5678")
  end

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

  describe "#author" do
    it "returns the officer's name" do
      expect(ballot_sheet.author).to be(ballot_sheet.officer_assignment.officer.user.name)
    end
  end

  describe "#verify_ballots" do
    it "creates ballots for each document number" do
      poll = create(:poll, :for_budget)
      poll_ballot = create(:poll_ballot_sheet, poll: poll, data: "1,2,3;4,5,6")
      poll_ballot.verify_ballots

      expect(Poll::Ballot.count).to eq(2)
      expect(Budget::Ballot.count).to eq(2)
    end
  end

  describe "#parsed_ballots" do
    it "splits ballots by ';' or '\n'" do
      data = "1,2,3;4,5,6\n7,8,9"
      ballot_sheet.update!(data: data)

      expect(ballot_sheet.parsed_ballots).to eq(["1,2,3", "4,5,6", "7,8,9"])
    end
  end
end
