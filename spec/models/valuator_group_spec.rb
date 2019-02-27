require "rails_helper"

describe ValuatorGroup do

  describe "Validations" do
    it "should be valid" do
      expect(build(:valuator_group)).to be_valid
    end

    it "should not be valid without a name" do
      expect(build(:valuator_group, name: nil)).not_to be_valid
    end

    it "should not be valid with the same name as an existing one" do
      create(:valuator_group, name: "The Valuators")

      expect(build(:valuator_group, name: "The Valuators")).not_to be_valid
    end
  end
end
