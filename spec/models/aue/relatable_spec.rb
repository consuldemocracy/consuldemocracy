require "rails_helper"

describe AUE::Relatable do
  let(:goal) { AUE::Goal[1] }
  let(:another_goal) { AUE::Goal[2] }

  let(:relatable) { create(:proposal) }

  describe "#aue_goals" do
    it "can assign goals to a model" do
      relatable.aue_goals = [goal, another_goal]

      expect(AUE::Relation.count).to be 2
      expect(AUE::Relation.first.relatable).to eq relatable
      expect(AUE::Relation.last.relatable).to eq relatable
      expect(AUE::Relation.first.related_aue).to eq goal
      expect(AUE::Relation.last.related_aue).to eq another_goal
    end

    it "can obtain the list of goals" do
      relatable.aue_goals = [goal, another_goal]

      expect(relatable.reload.aue_goals).to match_array [goal, another_goal]
    end
  end

  describe "#aue_goal_list" do
    it "orders goals by code" do
      relatable.aue_goals = [AUE::Goal[1], AUE::Goal[3], AUE::Goal[2]]

      expect(relatable.aue_goal_list).to eq "1, 2, 3"
    end
  end


  describe "#related_aue_list=" do
    it "assigns a single goal" do
      relatable.related_aue_list = "1"

      expect(relatable.reload.aue_goals).to match_array [AUE::Goal[1]]
    end

    it "assigns multiple goals" do
      relatable.related_aue_list = "3,2,1"

      expect(relatable.reload.aue_goals).to match_array [AUE::Goal[1], AUE::Goal[2], AUE::Goal[3]]
    end
  end

  describe ".by_aue_goal" do
    it "returns everything if no code is provided" do
      expect(relatable.class.by_aue_goal("")).to eq [relatable]
      expect(relatable.class.by_aue_goal(nil)).to eq [relatable]
    end

    it "returns records associated with that goal" do
      same_association = create(:proposal, aue_goals: [goal])
      both_associations = create(:proposal, aue_goals: [goal, another_goal])

      expect(relatable.class.by_aue_goal(goal.code)).to match_array [same_association, both_associations]
    end

    it "does not return records not associated with that goal" do
      create(:proposal)
      create(:proposal, aue_goals: [another_goal])

      expect(relatable.class.by_aue_goal(goal.code)).to be_empty
    end
  end

end
