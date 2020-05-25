require "rails_helper"

describe StatsVersion do
  describe "validations" do
    it "is valid with a process" do
      expect(StatsVersion.new(process: Budget.new)).to be_valid
    end

    it "is not valid without a process" do
      expect(StatsVersion.new(process: nil)).not_to be_valid
    end
  end
end
