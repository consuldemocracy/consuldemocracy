require "rails_helper"

describe SDG::Relatable do
  let(:goal) { SDG::Goal[1] }
  let(:target) { SDG::Target["1.2"] }
  let(:local_target) { create(:sdg_local_target, code: "1.2.1") }
  let(:another_goal) { SDG::Goal[2] }
  let(:another_target) { SDG::Target["2.3"] }
  let(:another_local_target) { create(:sdg_local_target, code: "2.3.1") }

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

  describe "#sdg_goal_list" do
    it "orders goals by code" do
      relatable.sdg_goals = [SDG::Goal[1], SDG::Goal[3], SDG::Goal[2]]

      expect(relatable.sdg_goal_list).to eq "1, 2, 3"
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

  describe "#sdg_target_list" do
    it "orders targets by code" do
      relatable.sdg_targets = [SDG::Target[2.2], SDG::Target[1.2], SDG::Target[2.1]]

      expect(relatable.sdg_target_list).to eq "1.2, 2.1, 2.2"
    end
  end

  describe "#sdg_local_targets" do
    it "can assign local targets to a model" do
      relatable.sdg_local_targets = [local_target, another_local_target]

      expect(SDG::Relation.count).to be 2
      expect(SDG::Relation.first.relatable).to eq relatable
      expect(SDG::Relation.last.relatable).to eq relatable
      expect(SDG::Relation.first.related_sdg).to eq local_target
      expect(SDG::Relation.last.related_sdg).to eq another_local_target
    end

    it "can obtain the list of local targets" do
      relatable.sdg_local_targets = [local_target, another_local_target]

      expect(relatable.reload.sdg_local_targets).to match_array [local_target, another_local_target]
    end
  end

  describe "#related_sdgs" do
    it "returns all related goals and targets" do
      relatable.sdg_goals = [goal, another_goal]
      relatable.sdg_targets = [target, another_target]
      relatable.sdg_local_targets = [local_target, another_local_target]

      related_sdgs = [goal, another_goal, target, another_target, local_target, another_local_target]
      expect(relatable.reload.related_sdgs).to match_array related_sdgs
    end
  end

  describe "#sdg_target_list=" do
    it "assigns a single target" do
      relatable.sdg_target_list = "1.1"

      expect(relatable.reload.sdg_targets).to match_array [SDG::Target["1.1"]]
    end

    it "assigns multiple targets" do
      relatable.sdg_target_list = "1.1,2.3"

      expect(relatable.reload.sdg_targets).to match_array [SDG::Target["1.1"], SDG::Target["2.3"]]
    end

    it "ignores trailing spaces and spaces between commas" do
      relatable.sdg_target_list = " 1.1,  2.3 "

      expect(relatable.reload.sdg_targets).to match_array [SDG::Target["1.1"], SDG::Target["2.3"]]
    end

    it "assigns goals" do
      relatable.sdg_target_list = "1.1,1.2,2.3"

      expect(relatable.reload.sdg_goals).to match_array [SDG::Goal[1], SDG::Goal[2]]
    end
  end

  describe ".by_goal" do
    it "returns everything if no code is provided" do
      expect(relatable.class.by_goal("")).to eq [relatable]
      expect(relatable.class.by_goal(nil)).to eq [relatable]
    end

    it "returns records associated with that goal" do
      same_association = create(:proposal, sdg_goals: [goal])
      both_associations = create(:proposal, sdg_goals: [goal, another_goal])

      expect(relatable.class.by_goal(goal.code)).to match_array [same_association, both_associations]
    end

    it "does not return records not associated with that goal" do
      create(:proposal)
      create(:proposal, sdg_goals: [another_goal])

      expect(relatable.class.by_goal(goal.code)).to be_empty
    end
  end

  describe ".by_target" do
    it "returns everything if no code is provided" do
      expect(relatable.class.by_target("")).to eq [relatable]
      expect(relatable.class.by_target(nil)).to eq [relatable]
    end

    it "returns records associated with that target" do
      same_association = create(:proposal, sdg_targets: [target])
      both_associations = create(:proposal, sdg_targets: [target, another_target])

      expect(relatable.class.by_target(target.code)).to match_array [same_association, both_associations]
    end

    it "does not return records not associated with that target" do
      create(:proposal)
      create(:proposal, sdg_targets: [another_target])

      expect(relatable.class.by_target(target.code)).to be_empty
    end
  end
end
