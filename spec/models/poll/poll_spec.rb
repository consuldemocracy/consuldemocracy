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
end