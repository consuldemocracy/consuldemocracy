require "rails_helper"

describe SDG::Goal do
  it "is valid" do
    expect(build(:sdg_goal)).to be_valid
  end

  it "is not valid without a code" do
    expect(build(:sdg_goal, code: nil)).not_to be_valid
  end

  it "is not valid without a title" do
    expect(build(:sdg_goal, title: "")).not_to be_valid
  end

  it "is not valid with an already used title" do
    create(:sdg_goal, title: "No Poverty")

    duplicate = build(:sdg_goal, title: "No Poverty")
    duplicate.save

    expect(duplicate).not_to be_valid
  end

  it "is valid with the same title for a different locale" do
    create(:sdg_goal, title: "Zero Hunger")

    I18n.with_locale(:es) do
      goal = build(:sdg_goal, title: "Zero Hunger")

      expect(goal).to be_valid
    end
  end

  it "is not valid without a description" do
    expect(build(:sdg_goal, description: "")).not_to be_valid
  end
end
