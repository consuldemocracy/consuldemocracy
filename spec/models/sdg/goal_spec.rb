require "rails_helper"

describe SDG::Goal do
  it "is valid" do
    expect(build(:sdg_goal)).to be_valid
  end

  it "is not valid without a code" do
    expect(build(:sdg_goal, code: nil)).not_to be_valid
  end

  it "translates title" do
    goal = SDG::Goal.where(code: "1").first_or_create!

    expect(goal.title).to eq "No Poverty"

    I18n.with_locale(:es) do
      expect(goal.title).to eq "Fin de la pobreza"
    end
  end

  it "translates description" do
    goal = SDG::Goal.where(code: "1").first_or_create!

    expect(goal.description).to eq "End poverty in all its forms, everywhere."

    I18n.with_locale(:es) do
      expect(goal.description).to eq "Poner fin a la pobreza en todas sus formas en todo el mundo."
    end
  end
end
