require "rails_helper"

describe Geozone do
  let(:geozone) { build(:geozone) }

  it "is valid" do
    expect(geozone).to be_valid
  end

  it "is not valid without a name" do
    geozone.name = nil
    expect(geozone).not_to be_valid
  end

  describe "#safe_to_destroy?" do
    let(:geozone) { create(:geozone) }

    it "is true when not linked to other models" do
      expect(geozone).to be_safe_to_destroy
    end

    it "is false when already linked to user" do
      create(:user, geozone: geozone)
      expect(geozone).not_to be_safe_to_destroy
    end

    it "is false when already linked to proposal" do
      create(:proposal, geozone: geozone)
      expect(geozone).not_to be_safe_to_destroy
    end

    it "is false when already linked to debate" do
      create(:debate, geozone: geozone)
      expect(geozone).not_to be_safe_to_destroy
    end
  end
end

# == Schema Information
#
# Table name: geozones
#
#  id                   :integer          not null, primary key
#  name                 :string
#  html_map_coordinates :string
#  external_code        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  census_code          :string
#
