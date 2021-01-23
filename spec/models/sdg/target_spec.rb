require "rails_helper"

describe SDG::Target do
  it "is valid" do
    expect(build(:sdg_target, code: "1.Z", goal: SDG::Goal[1])).to be_valid
  end

  it "is not valid without a code" do
    expect(build(:sdg_target, code: nil)).not_to be_valid
  end

  it "is not valid without a goal" do
    target = build(:sdg_target, goal: nil)

    expect(target).not_to be_valid
  end

  it "is not valid if code is not unique" do
    goal = SDG::Goal[1]
    create(:sdg_target, code: "1.Z", goal: goal)
    target = build(:sdg_target, code: "1.Z", goal: goal)

    expect(target).not_to be_valid
    expect(target.errors.full_messages).to include "Code has already been taken"
  end

  it "translates title" do
    target = SDG::Target["1.1"]

    expect(target.title).to start_with "By 2030, eradicate extreme poverty"

    I18n.with_locale(:es) do
      expect(target.title).to start_with "Para 2030, erradicar la pobreza extrema"
    end

    target = SDG::Target["17.11"]

    expect(target.title).to start_with "Significantly increase the exports of developing countries"

    I18n.with_locale(:es) do
      expect(target.title).to start_with "Aumentar significativamente las exportaciones de los países"
    end
  end

  describe "#<=>" do
    let(:goal)   { build(:sdg_goal, code: 10) }
    let(:target) { build(:sdg_target, code: "10.19", goal: goal) }

    it "compares using the goal first" do
      lesser_target = build(:sdg_target, code: "2.14", goal: build(:sdg_goal, code: 2))
      greater_target = build(:sdg_target, code: "11.1", goal: build(:sdg_goal, code: 11))

      expect(target).to be > lesser_target
      expect(target).to be < greater_target
    end

    it "compares using the target code when the goal is the same" do
      lesser_target = build(:sdg_target, code: "10.2", goal: goal)
      greater_target = build(:sdg_target, code: "10.A", goal: goal)

      expect(target).to be > lesser_target
      expect(target).to be < greater_target
    end

    context "comparing with a local target" do
      it "compares using the goal first" do
        lesser_local_target = build(:sdg_local_target, code: "2.1.1")
        greater_local_target = build(:sdg_local_target, code: "11.1.2")

        expect(target).to be > lesser_local_target
        expect(target).to be < greater_local_target
      end

      it "compares using the target when the goal is the same" do
        lesser_target = build(:sdg_target, code: "10.2", goal: goal)
        greater_target = build(:sdg_target, code: "10.A", goal: goal)
        lesser_local_target = build(:sdg_local_target, code: "10.2.25", target: lesser_target)
        greater_local_target = build(:sdg_local_target, code: "10.A.1", target: greater_target)

        expect(target).to be > lesser_local_target
        expect(target).to be < greater_local_target
      end

      it "is smaller than a local target belonging to it" do
        local_target = build(:sdg_local_target, target: target, code: "10.19.1")

        expect(target).to be < local_target
      end
    end

    it "can be compared against goals" do
      lesser_goal = build(:sdg_goal, code: "9")
      greater_goal = build(:sdg_goal, code: "11")

      expect(target).to be > lesser_goal
      expect(target).to be < greater_goal
    end
  end

  describe ".[]" do
    it "finds existing targets by code" do
      expect(SDG::Target["1.1"].code).to eq "1.1"
    end

    it "raises an exception for non-existing codes" do
      expect { SDG::Target["Z.j3"] }.to raise_exception ActiveRecord::RecordNotFound
    end
  end
end
