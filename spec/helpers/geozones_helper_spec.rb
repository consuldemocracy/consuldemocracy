require 'rails_helper'

describe GeozonesHelper do

  describe "#geozones_name" do
    let(:geozone) { create :geozone }


    it "returns geozone name if present" do
      spending_proposal = create(:spending_proposal, geozone: geozone)
      expect(geozone_name(spending_proposal)).to eq geozone.name
    end

    it "returns default string for no geozone if geozone is blank" do
      spending_proposal = create(:spending_proposal, geozone: nil)
      expect(geozone_name(spending_proposal)).to eq "All city"
    end
  end


end
