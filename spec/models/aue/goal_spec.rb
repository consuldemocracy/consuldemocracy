require "rails_helper"

describe AUE::Goal do
  describe "validations" do
    it "is valid with an existent code" do
      goal = AUE::Goal[1]

      expect(goal).to be_valid
    end

    it "is not valid without a code" do
      expect(build(:aue_goal, code: nil)).not_to be_valid
    end

    it "is not valid with a nonexistent code" do
      [0, 18].each do |code|
        goal = AUE::Goal.where(code: code).first_or_initialize

        expect(goal).not_to be_valid
      end
    end
  end

  describe "#<=>" do
    let(:goal) { AUE::Goal[5] }

    it "can be compared against goals" do
      lesser_goal = AUE::Goal[4]
      greater_goal = AUE::Goal[6]

      expect(goal).to be > lesser_goal
      expect(goal).to be < greater_goal
    end
  end

  describe ".[]" do
    it "finds existing goals by code" do
      expect(AUE::Goal[1].code).to be 1
    end

    it "raises an exception for non-existing codes" do
      expect { AUE::Goal[100] }.to raise_exception ActiveRecord::RecordNotFound
    end
  end

  it "translates title" do
    goal = AUE::Goal[1]

    I18n.with_locale(:es) do
      expect(goal.title).to eq "Objetivo Estratégico 1"
    end
  end

  it "translates description" do
    goal = AUE::Goal[1]

    I18n.with_locale(:es) do
      expect(goal.description).to eq "Ordenar el territorio y hacer un uso racional del suelo, conservarlo y protegerlo."
    end
  end

end
