require "rails_helper"

describe GeozonesHelper do
  describe "#geozone_name" do
    let(:geozone) { create :geozone }

    it "returns geozone name if present" do
      proposal = create(:proposal, geozone: geozone)
      expect(geozone_name(proposal)).to eq geozone.name
    end

    it "returns default string for no geozone if geozone is blank" do
      proposal = create(:proposal, geozone: nil)
      expect(geozone_name(proposal)).to eq "All city"
    end
  end

  describe "#geozone_select_options" do
    it "returns array of ids and names ordered by name" do
      g1 = create(:geozone, name: "AAA")
      g3 = create(:geozone, name: "CCC")
      g2 = create(:geozone, name: "BBB")

      select_options = geozone_select_options

      expect(select_options).to eq [[g1.name, g1.id], [g2.name, g2.id], [g3.name, g3.id]]
    end
  end
end
