require 'rails_helper'

describe Ballot do

  describe "#amount_spent" do
    it "returns the amount spent in spending proposals" do
      sp1 = create(:spending_proposal, price: 10000)
      sp2 = create(:spending_proposal, price: 20000)

      ballot = create(:ballot)
      ballot.spending_proposals << sp1

      expect(ballot.amount_spent).to eq 10000

      ballot.spending_proposals << sp2

      expect(ballot.amount_spent).to eq 30000
    end
  end

  describe "#city_wide_amount_available" do
    it "returns the amount available to spend on city_wide spending proposals" do
      sp1 = create(:spending_proposal, price: 10000)
      sp2 = create(:spending_proposal, price: 20000)

      ballot = create(:ballot)
      ballot.spending_proposals << sp1

      expect(ballot.city_wide_amount_available).to eq 23990000

      ballot.spending_proposals << sp2

      expect(ballot.city_wide_amount_available).to eq 23970000
    end
  end

  describe "#district_wide_amount_available" do
    it "returns the amount available to spend on city_wide spending proposals" do
      geozone =  create(:geozone)
      sp1 = create(:spending_proposal, price: 20000, geozone: geozone)
      sp2 = create(:spending_proposal, price: 30000, geozone: geozone)

      ballot = create(:ballot)
      ballot.spending_proposals << sp1

      expect(ballot.district_wide_amount_available).to eq 23980000

      ballot.spending_proposals << sp2

      expect(ballot.district_wide_amount_available).to eq 23950000
    end
  end

  describe "#valid_spending_proposal?" do
    it "returns false if wrong geozone" do
      sp = create(:spending_proposal, price: 20000, geozone: create(:geozone))
      ballot = create(:ballot, geozone: create(:geozone))

      expect(ballot.valid_spending_proposal?(sp)).to eq false
    end

    it "returns false if right geozone but no money available" do
      geozone = create(:geozone)
      sp = create(:spending_proposal, price: 25000000, geozone: geozone)
      ballot = create(:ballot, geozone: geozone)
      ballot2 = create(:ballot)

      expect(ballot.valid_spending_proposal?(sp)).to eq false
      expect(ballot2.valid_spending_proposal?(sp)).to eq false
    end

    it "returns false if city-wide proposal but no money available" do
      sp = create(:spending_proposal, price: 25000000)
      ballot = create(:ballot, geozone: create(:geozone))
      ballot2 = create(:ballot)

      expect(ballot.valid_spending_proposal?(sp)).to eq false
      expect(ballot2.valid_spending_proposal?(sp)).to eq false
    end

    it "returns true if city-wide proposal and money vailable" do
      sp = create(:spending_proposal, price: 20000)
      ballot = create(:ballot)

      expect(ballot.valid_spending_proposal?(sp)).to eq true
    end

    it "returns true if geozone-wide proposal and money vailable" do
      geozone = create(:geozone)
      sp = create(:spending_proposal, price: 25000, geozone: geozone)
      ballot = create(:ballot, geozone: geozone)
      ballot2 = create(:ballot)

      expect(ballot.valid_spending_proposal?(sp)).to eq true
      expect(ballot2.valid_spending_proposal?(sp)).to eq true
    end
  end

end