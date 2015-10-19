require 'rails_helper'

describe Verification::Management::Document do
  describe "#valid_age?" do
    it "returns false when the user is younger than sixteen years old" do
      census_response = double(date_of_birth: "31-12-#{16.years.ago.year}")
      expect(Verification::Management::Document.new.valid_age?(census_response)).to be false
    end

    it "returns true when the user is sixteen years old" do
      census_response = double(date_of_birth: 16.years.ago.strftime("%d-%m-%Y"))
      expect(Verification::Management::Document.new.valid_age?(census_response)).to be true
    end

    it "returns true when the user is older than sixteen years old" do
      census_response = double(date_of_birth: "31-12-#{33.years.ago.year}")
      expect(Verification::Management::Document.new.valid_age?(census_response)).to be true
    end
  end

  describe "#under_sixteen?" do
    it "returns true when the user is younger than sixteen years old" do
      census_response = double(date_of_birth: "31-12-#{16.years.ago.year}")
      expect(Verification::Management::Document.new.under_sixteen?(census_response)).to be true
    end

    it "returns false when the user is sixteen years old" do
      census_response = double(date_of_birth: 16.years.ago.strftime("%d-%m-%Y"))
      expect(Verification::Management::Document.new.under_sixteen?(census_response)).to be false
    end

    it "returns false when the user is older than sixteen years old" do
      census_response = double(date_of_birth: "31-12-#{33.years.ago.year}")
      expect(Verification::Management::Document.new.under_sixteen?(census_response)).to be false
    end
  end
end