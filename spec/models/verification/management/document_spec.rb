require 'rails_helper'

describe Verification::Management::Document do
  describe "#valid_age?" do
    it "returns false when the user is younger than the user's minimum required age" do
      census_response = double(date_of_birth: Date.new(User.minimum_required_age.years.ago.year, 12, 31))
      expect(Verification::Management::Document.new.valid_age?(census_response)).to be false
    end

    it "returns true when the user has the user's minimum required age" do
      census_response = double(date_of_birth: Date.new(User.minimum_required_age.years.ago.year, 16.years.ago.month, 16.years.ago.day))
      expect(Verification::Management::Document.new.valid_age?(census_response)).to be true
    end

    it "returns true when the user is older than the user's minimum required age" do
      census_response = double(date_of_birth: Date.new((User.minimum_required_age + 10).years.ago.year, 12, 31))
      expect(Verification::Management::Document.new.valid_age?(census_response)).to be true
    end
  end

  describe "#under_age?" do
    it "returns true when the user is younger than the user's minimum required age" do
      census_response = double(date_of_birth: Date.new(User.minimum_required_age.years.ago.year, 12, 31))
      expect(Verification::Management::Document.new.under_age?(census_response)).to be true
    end

    it "returns false when the user is user's minimum required age" do
      date_of_birth = Date.new(User.minimum_required_age.years.ago.year,
                      User.minimum_required_age.years.ago.month,
                      User.minimum_required_age.years.ago.day)
      census_response = double(date_of_birth: date_of_birth)
      expect(Verification::Management::Document.new.under_age?(census_response)).to be false
    end

    it "returns false when the user is older than user's minimum required age" do
      census_response = double(date_of_birth: Date.new((User.minimum_required_age + 10).years.ago.year, 12, 31))
      expect(Verification::Management::Document.new.under_age?(census_response)).to be false
    end
  end
end
