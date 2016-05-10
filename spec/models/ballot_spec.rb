require 'rails_helper'

describe Ballot do

  describe "#amount_spent" do
    it "returns the total amount spent in spending proposals" do
      sp1 = create(:spending_proposal, price: 10000)
      sp2 = create(:spending_proposal, price: 20000)

      ballot = create(:ballot)
      ballot.spending_proposals << sp1

      expect(ballot.total_amount_spent).to eq 10000

      ballot.spending_proposals << sp2

      expect(ballot.total_amount_spent).to eq 30000
    end
  end

  describe "#amount_available city_wide" do
    it "returns the amount available to spend on city_wide spending proposals" do
      sp1 = create(:spending_proposal, price: 10000)
      sp2 = create(:spending_proposal, price: 20000)

      ballot = create(:ballot)
      ballot.spending_proposals << sp1

      expect(ballot.amount_available(nil)).to eq 23990000

      ballot.spending_proposals << sp2

      expect(ballot.amount_available(nil)).to eq 23970000
    end
  end

  describe "#amount_available district_wide" do
    it "returns the amount available to spend on city_wide spending proposals" do
      geozone =  create(:geozone)
      sp1 = create(:spending_proposal, price: 20000, geozone: geozone)
      sp2 = create(:spending_proposal, price: 30000, geozone: geozone)

      ballot = create(:ballot)
      ballot.spending_proposals << sp1

      expect(ballot.amount_available(geozone)).to eq 23980000

      ballot.spending_proposals << sp2

      expect(ballot.amount_available(geozone)).to eq 23950000
    end
  end

  ### Move to ballot_line_spec.rb
  describe "#valid_spending_proposal?" do
    it "returns false if spending proposal is unfeasible" do
      sp = create(:spending_proposal, price: 20000, feasible: false)
      ballot = create(:ballot)

      expect(ballot.valid_spending_proposal?(sp)).to eq false
    end

    it "returns false if spending_proposal feasibility is undedided" do
      sp = create(:spending_proposal, price: 20000, feasible: nil)
      ballot = create(:ballot)

      expect(ballot.valid_spending_proposal?(sp)).to eq false
    end
  end
  ###

end