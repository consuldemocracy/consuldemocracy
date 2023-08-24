require "rails_helper"

describe Budget::Phase do
  describe "validates" do
    it "is not valid without a start date" do
      expect(build(:budget_phase, starts_at: nil)).not_to be_valid
    end

    it "is not valid without an end date" do
      expect(build(:budget_phase, ends_at: nil)).not_to be_valid
    end
  end
end
