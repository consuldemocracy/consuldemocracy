require "rails_helper"

describe SDG::Relatable do
  let(:goal) { SDG::Goal[1] }
  let(:target) { SDG::Target["1.2"] }
  let(:another_goal) { SDG::Goal[2] }
  let(:another_target) { SDG::Target["2.3"] }

  let(:relatable) { create(:proposal) }

  describe "#sdg_goals" do
    it "can assign goals to a model" do
      relatable.sdg_goals = [goal, another_goal]

      expect(SDG::Relation.count).to be 2
      expect(SDG::Relation.first.relatable).to eq relatable
      expect(SDG::Relation.last.relatable).to eq relatable
      expect(SDG::Relation.first.related_sdg).to eq goal
      expect(SDG::Relation.last.related_sdg).to eq another_goal
    end

    it "can obtain the list of goals" do
      relatable.sdg_goals = [goal, another_goal]

      expect(relatable.reload.sdg_goals).to match_array [goal, another_goal]
    end
  end

  describe "#sdg_targets" do
    it "can assign targets to a model" do
      relatable.sdg_targets = [target, another_target]

      expect(SDG::Relation.count).to be 2
      expect(SDG::Relation.first.relatable).to eq relatable
      expect(SDG::Relation.last.relatable).to eq relatable
      expect(SDG::Relation.first.related_sdg).to eq target
      expect(SDG::Relation.last.related_sdg).to eq another_target
    end

    it "can obtain the list of targets" do
      relatable.sdg_targets = [target, another_target]

      expect(relatable.reload.sdg_targets).to match_array [target, another_target]
    end
  end

  describe "#related_sdgs" do
    it "returns all related goals and targets" do
      relatable.sdg_goals = [goal, another_goal]
      relatable.sdg_targets = [target, another_target]

      expect(relatable.reload.related_sdgs).to match_array [goal, another_goal, target, another_target]
    end
  end
end
