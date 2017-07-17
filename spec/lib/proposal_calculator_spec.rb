require 'rails_helper'

describe ProposalCalculator do

  describe "mark_as_undecided?" do
    it "returns true if below required number of votes, has votes, feasible and not reclassified" do
      spending_proposal = create(:spending_proposal, :feasible, id: 99999, cached_votes_up: 5)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.mark_as_undecided?).to eq true
    end

    it "returns true if below required number of votes, has votes, unfeasible and not reclassified" do
      spending_proposal = create(:spending_proposal, :unfeasible, id: 99999, cached_votes_up: 5)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.mark_as_undecided?).to eq true
    end

    it "returns false if above required number of votes" do
      spending_proposal = create(:spending_proposal, :feasible, cached_votes_up: 500)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.mark_as_undecided?).to eq false
    end

    it "returns false if 0 votes" do
      spending_proposal = create(:spending_proposal, :feasible, cached_votes_up: 0, physical_votes: 0)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.mark_as_undecided?).to eq false
    end

    it "returns false if included in reclassified list" do
      spending_proposal = create(:spending_proposal, :feasible, id: 4517)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.mark_as_undecided?).to eq false
    end
  end

  describe "#minimum_votes?" do
    it "returns minimum required number of votes for a district" do
      carabanchel = create(:geozone, name: 'Carabanchel')
      spending_proposal = create(:spending_proposal, geozone: carabanchel)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.minimum_votes?(carabanchel)).to eq 37
    end

    it "returns minimum required number of votes for a city" do
      spending_proposal = create(:spending_proposal, geozone: nil)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.minimum_votes?(nil)).to eq 52
    end
  end

  describe "#insufficient_votes?" do
    it "returns true if below required number of votes" do
      carabanchel = create(:geozone, name: 'Carabanchel')
      spending_proposal = create(:spending_proposal, geozone: carabanchel, cached_votes_up: 36)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.insufficient_votes?).to eq true
    end

    it "returns false if above required number of votes" do
      carabanchel = create(:geozone, name: 'Carabanchel')
      spending_proposal = create(:spending_proposal, geozone: carabanchel, cached_votes_up: 37)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.insufficient_votes?).to eq false
    end
  end

  describe "#has_votes?" do
    it "returns true if it has more than 0 votes" do
      spending_proposal = create(:spending_proposal, cached_votes_up: 1)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.has_votes?).to eq true
    end

    it "returns true if it has more than 0 physical votes" do
      spending_proposal = create(:spending_proposal, cached_votes_up: 0, physical_votes: 1)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.has_votes?).to eq true
    end

    it "returns false if it has 0 votes" do
      spending_proposal = create(:spending_proposal, :feasible, cached_votes_up: 0, physical_votes: 0)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.has_votes?).to eq false
    end
  end

  describe "#reclassified?" do
    it "returns true if included in reclassified list" do
      spending_proposal = create(:spending_proposal, id: 4517)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.reclassified?).to eq true
    end

    it "returns false if not included in reclassified list" do
      spending_proposal = create(:spending_proposal, id: 99999)
      calculator = ProposalCalculator.new(spending_proposal)

      expect(calculator.reclassified?).to eq false
    end
  end

end