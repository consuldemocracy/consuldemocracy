require 'rails_helper'

describe Ballot do

  describe "#amount_spent" do
    it "returns the total amount spent in spending proposals" do
      sp1 = create(:spending_proposal, :feasible, price: 10000)
      sp2 = create(:spending_proposal, :feasible, price: 20000)

      ballot = create(:ballot)
      ballot.spending_proposals << sp1

      expect(ballot.total_amount_spent).to eq 10000

      ballot.spending_proposals << sp2

      expect(ballot.total_amount_spent).to eq 30000
    end
  end

  describe "#amount_available city_wide" do
    it "returns the amount available to spend on city_wide spending proposals" do
      sp1 = create(:spending_proposal, :feasible, price: 10000)
      sp2 = create(:spending_proposal, :feasible, price: 20000)

      ballot = create(:ballot)
      ballot.spending_proposals << sp1

      expect(ballot.amount_available(nil)).to eq 23990000

      ballot.spending_proposals << sp2

      expect(ballot.amount_available(nil)).to eq 23970000
    end
  end

  describe "#amount_available district_wide" do
    it "returns the amount available to spend on district_wide spending proposals" do
      geozone = create(:geozone, name: "Centro")
      sp1 = create(:spending_proposal, :feasible, price: 20000, geozone: geozone)
      sp2 = create(:spending_proposal, :feasible, price: 30000, geozone: geozone)

      ballot = create(:ballot)

      expect(ballot.initial_budget(geozone)).to eq 1353966

      ballot.spending_proposals << sp1

      expect(ballot.amount_available(geozone)).to eq 1333966

      ballot.spending_proposals << sp2

      expect(ballot.amount_available(geozone)).to eq 1303966
    end
  end

  describe "#has_district_wide_votes?" do
    it "returns true if ballot has a geozone locked" do
      ballot = create(:ballot)
      expect(ballot.has_district_wide_votes?).to eq false

      ballot.geozone = create(:geozone)
      expect(ballot.has_district_wide_votes?).to eq true
    end
  end

  describe "#has_city_wide_votes?" do
    it "returns true if ballot includes a ballot line with a city-wide proposal" do
      ballot = create(:ballot)
      expect(ballot.has_city_wide_votes?).to eq false

      sp1 = create(:spending_proposal, :feasible, price: 20000, geozone: create(:geozone, name: "Centro"))

      ballot.spending_proposals << sp1
      expect(ballot.has_city_wide_votes?).to eq false

      sp2 = create(:spending_proposal, :feasible, price: 30000, geozone: nil)
      ballot.spending_proposals << sp2
      expect(ballot.has_city_wide_votes?).to eq true
    end
  end
end