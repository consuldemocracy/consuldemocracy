require "rails_helper"

describe AUE::Related do
  let(:proposal) { create(:proposal) }
  let(:another_proposal) { create(:proposal) }
  let(:related_aue) { AUE::Goal[1] }

  describe "#proposals" do
    it "can assign proposals to a model" do
      related_aue.proposals = [proposal, another_proposal]

      expect(AUE::Relation.count).to be 2
      expect(AUE::Relation.first.related_aue).to eq related_aue
      expect(AUE::Relation.last.related_aue).to eq related_aue
      expect(AUE::Relation.first.relatable).to eq proposal
      expect(AUE::Relation.last.relatable).to eq another_proposal
    end

    it "can obtain the list of proposals" do
      related_aue.proposals = [proposal, another_proposal]

      expect(related_aue.reload.proposals).to match_array [proposal, another_proposal]
    end
  end
end
