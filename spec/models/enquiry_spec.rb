require 'rails_helper'

RSpec.describe Enquiry, type: :model do
  describe "#opened?" do
    it "returns true only when it isn't too early or too late" do
      expect(create(:enquiry, :incoming)).to_not be_opened
      expect(create(:enquiry, :expired)).to_not be_opened
      expect(create(:enquiry)).to be_opened
    end
  end

  describe "#incoming?" do
    it "returns true only when it is too early" do
      expect(create(:enquiry, :incoming)).to be_incoming
      expect(create(:enquiry, :expired)).to_not be_incoming
      expect(create(:enquiry)).to_not be_incoming
    end
  end

  describe "#expired?" do
    it "returns true only when it is too late" do
      expect(create(:enquiry, :incoming)).to_not be_expired
      expect(create(:enquiry, :expired)).to be_expired
      expect(create(:enquiry)).to_not be_expired
    end
  end


end
