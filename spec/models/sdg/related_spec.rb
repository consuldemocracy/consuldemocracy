require "rails_helper"

describe SDG::Related do
  let(:proposal) { create(:proposal) }
  let(:another_proposal) { create(:proposal) }
  let(:related_sdg) { SDG::Goal[1] }

  describe "#proposals" do
    it "can assign proposals to a model" do
      related_sdg.proposals = [proposal, another_proposal]

      expect(SDG::Relation.count).to be 2
      expect(SDG::Relation.first.related_sdg).to eq related_sdg
      expect(SDG::Relation.last.related_sdg).to eq related_sdg
      expect(SDG::Relation.first.relatable).to eq proposal
      expect(SDG::Relation.last.relatable).to eq another_proposal
    end

    it "can obtain the list of proposals" do
      related_sdg.proposals = [proposal, another_proposal]

      expect(related_sdg.reload.proposals).to match_array [proposal, another_proposal]
    end
  end

  describe "#relatables" do
    let(:investment) { create(:budget_investment) }

    it "returns all related content" do
      related_sdg.proposals = [proposal, another_proposal]
      related_sdg.budget_investments = [investment]

      expect(related_sdg.reload.relatables).to match_array [proposal, another_proposal, investment]
    end
  end
end
