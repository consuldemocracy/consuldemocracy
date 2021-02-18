require "rails_helper"

describe SDG::LocalTarget do
  describe "Concerns" do
    it_behaves_like "globalizable", :sdg_local_target
  end

  it "is valid" do
    expect(build(:sdg_local_target)).to be_valid
  end

  it "is not valid without a title" do
    expect(build(:sdg_local_target, title: nil)).not_to be_valid
  end

  it "is not valid without a description" do
    expect(build(:sdg_local_target, description: nil)).not_to be_valid
  end

  it "is not valid without a code" do
    expect(build(:sdg_local_target, code: nil, target: SDG::Target[1.1], goal: SDG::Goal[1])).not_to be_valid
  end

  it "is not valid when code does not include associated target code" do
    local_target = build(:sdg_local_target, code: "1.6.1", target: SDG::Target[1.1])

    expect(local_target).not_to be_valid
    expect(local_target.errors.full_messages).to include "Code must start with the same code as its target followed by a dot and end with a number"
  end

  it "is not valid when local target code part is not a number" do
    local_target = build(:sdg_local_target, code: "1.1.A", target: SDG::Target[1.1])

    expect(local_target).not_to be_valid
    expect(local_target.errors.full_messages).to include "Code must start with the same code as its target followed by a dot and end with a number"
  end

  it "is not valid if code is not unique" do
    create(:sdg_local_target, code: "1.1.1")
    local_target = build(:sdg_local_target, code: "1.1.1")

    expect(local_target).not_to be_valid
    expect(local_target.errors.full_messages).to include "Code has already been taken"
  end

  it "is not valid without a target" do
    expect(build(:sdg_local_target, target: nil)).not_to be_valid
  end

  describe "#set_related_goal" do
    it "before validation set related goal" do
      local_target = build(:sdg_local_target, code: "1.1.1", target: SDG::Target["1.1"], goal: nil)

      expect(local_target).to be_valid
      expect(local_target.goal).to eq(SDG::Goal[1])
    end
  end

  describe "#goal" do
    it "returns the target goal" do
      local_target = create(:sdg_local_target, code: "1.1.1")

      expect(local_target.goal).to eq(SDG::Goal[1])
    end
  end

  describe "#<=>" do
    let(:local_target,) { create(:sdg_local_target, code: "10.B.10") }

    it "compares using the target first" do
      lesser_local_target = create(:sdg_local_target, code: "10.A.1")
      greater_local_target = create(:sdg_local_target, code: "11.1.1")

      expect(local_target).to be > lesser_local_target
      expect(local_target).to be < greater_local_target
    end

    it "compares using the local target code when the target is the same" do
      lesser_local_target = create(:sdg_local_target, code: "10.B.9")
      greater_local_target = create(:sdg_local_target, code: "10.B.11")

      expect(local_target).to be > lesser_local_target
      expect(local_target).to be < greater_local_target
    end

    it "can be compared against global targets" do
      lesser_target = build(:sdg_target, code: "10.A", goal: SDG::Goal[10])
      greater_target = build(:sdg_target, code: "11.1", goal: SDG::Goal[11])

      expect(local_target).to be > lesser_target
      expect(local_target).to be < greater_target
    end

    it "can be compared against goals" do
      lesser_goal = build(:sdg_goal, code: "10")
      greater_goal = build(:sdg_goal, code: "11")

      expect(local_target).to be > lesser_goal
      expect(local_target).to be < greater_goal
    end
  end

  describe ".[]" do
    it "finds existing local targets by code" do
      create(:sdg_local_target, code: "1.1.1")

      expect(SDG::LocalTarget["1.1.1"].code).to eq "1.1.1"
    end

    it "raises an exception for non-existing codes" do
      expect { SDG::LocalTarget["1.1.99"] }.to raise_exception ActiveRecord::RecordNotFound
    end
  end
end
