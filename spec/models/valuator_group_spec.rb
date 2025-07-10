require "rails_helper"

describe ValuatorGroup do
  describe "Validations" do
    it "is valid" do
      expect(build(:valuator_group)).to be_valid
    end

    it "is not valid without a name" do
      expect(build(:valuator_group, name: nil)).not_to be_valid
    end

    it "is not valid with the same name as an existing one" do
      create(:valuator_group, name: "The Valuators")

      expect(build(:valuator_group, name: "The Valuators")).not_to be_valid
    end
  end
end
