require 'rails_helper'

RSpec.describe Enquiry, type: :model do
  describe "#open?" do
    it "works when it is too early" do
      expect(create(:enquiry, open_at: Date.today + 1.days, closed_at: Date.today + 1.month)).to_not be_open
    end

    it "works with it is too late" do
      expect(create(:enquiry, open_at: 1.year.ago, closed_at: 1.month.ago)).to_not be_open
    end

    it "works in the middle" do
      expect(create(:enquiry, open_at: 1.year.ago, closed_at: Date.today + 1.month)).to be_open
    end
  end
end
