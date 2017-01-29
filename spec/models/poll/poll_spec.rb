require 'rails_helper'

describe :poll do

  let(:poll) { build(:poll) }

  describe "validations" do
    it "should be valid" do
      expect(poll).to be_valid
    end

    it "should not be valid without a name" do
      poll.name = nil
      expect(poll).to_not be_valid
    end

    it "should not be valid without a start date" do
      poll.starts_at = nil
      expect(poll).to_not be_valid
    end

    it "should not be valid without an end date" do
      poll.ends_at = nil
      expect(poll).to_not be_valid
    end

    it "should not be valid without a proper start/end date range" do
      poll.starts_at = 1.week.ago
      poll.ends_at = 2.months.ago
      expect(poll).to_not be_valid
    end
  end

  describe "#opened?" do
    it "returns true only when it isn't too early or too late" do
      expect(create(:poll, :incoming)).to_not be_current
      expect(create(:poll, :expired)).to_not be_current
      expect(create(:poll)).to be_current
    end
  end

  describe "#incoming?" do
    it "returns true only when it is too early" do
      expect(create(:poll, :incoming)).to be_incoming
      expect(create(:poll, :expired)).to_not be_incoming
      expect(create(:poll)).to_not be_incoming
    end
  end

  describe "#expired?" do
    it "returns true only when it is too late" do
      expect(create(:poll, :incoming)).to_not be_expired
      expect(create(:poll, :expired)).to be_expired
      expect(create(:poll)).to_not be_expired
    end
  end

  describe "#published?" do
    it "returns true only when published is true" do
      expect(create(:poll)).to_not be_published
      expect(create(:poll, :published)).to be_published
    end
  end

  describe "#document_has_voted?" do
    it "returns true if Poll::Voter with document exists" do
      poll = create(:poll)
      voter = create(:poll_voter, :valid_document, poll: poll)

      expect(poll.document_has_voted?(voter.document_number, voter.document_type)).to eq(true)
    end

    it "returns false if Poll::Voter with document does not exists" do
      poll_2 = create(:poll)
      voter = create(:poll_voter, :valid_document, poll: poll_2)

      expect(poll.document_has_voted?(voter.document_number, voter.document_type)).to eq(false)
    end
  end
end