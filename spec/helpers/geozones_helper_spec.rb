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

  describe "#geozone_select_options" do
    it "returns array of ids and names ordered by name" do
      g1 = create(:geozone, name: "AAA")
      g3 = create(:geozone, name: "CCC")
      g2 = create(:geozone, name: "BBB")

      select_options = geozone_select_options

      expect(select_options.size).to eq 3
      expect(select_options.first).to eq [g1.name, g1.id]
      expect(select_options[1]).to eq [g2.name, g2.id]
      expect(select_options.last).to eq [g3.name, g3.id]
    end
  end

  describe "#my_geozone" do
    it "returns true if it is your geozone" do
      california = create(:geozone)

      user = create(:user)
      ballot = create(:ballot, user: user, geozone: california)

      expect(my_geozone?(california,  ballot)).to eq true
    end

    it "returns false if you have choosen another geozone" do
      california = create(:geozone)
      new_york = create(:geozone)

      user = create(:user)
      ballot = create(:ballot, user: user, geozone: california)

      expect(my_geozone?(new_york,  ballot)).to eq false
    end

    it "returns false if there is no current geozone" do
      california = create(:geozone)

      user = create(:user)
      ballot = create(:ballot, user: user, geozone: california)

      expect(my_geozone?(nil,  ballot)).to eq false
    end

    it "returns false if there is no geozone in the ballot" do
      california = create(:geozone)

      user = create(:user)
      ballot = create(:ballot, user: user, geozone: nil)

      expect(my_geozone?(california,  ballot)).to eq false
    end
  end

  describe "#geozone_name_from_id" do

    it "returns geozone name if present" do
      g1 = create(:geozone, name: "AAA")
      g2 = create(:geozone, name: "BBB")

      expect(geozone_name_from_id(g1.id)).to eq "AAA"
      expect(geozone_name_from_id(g2.id)).to eq "BBB"
    end

    it "returns default string for no geozone if geozone is blank" do
      expect(geozone_name_from_id(nil)).to eq "All city"
    end
  end

end
