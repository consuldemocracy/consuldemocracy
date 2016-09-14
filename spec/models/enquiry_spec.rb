require 'rails_helper'

RSpec.describe Enquiry, type: :model do
  describe "#open?" do
    it "returns false when it is too early" do
      expect(create(:enquiry, open_at: 1.day.from_now, closed_at: 1.month.from_now)).to_not be_open
    end

    it "return false when it is too late" do
      expect(create(:enquiry, open_at: 1.year.ago, closed_at: 1.month.ago)).to_not be_open
    end

    it "returns true when it is neither too early nor too late" do
      expect(create(:enquiry, open_at: 1.year.ago, closed_at: 1.month.from_now)).to be_open
    end
  end
end
