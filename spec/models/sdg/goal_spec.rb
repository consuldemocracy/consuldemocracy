require "rails_helper"

describe SDG::Goal do
  describe "validations" do
    it "is valid with an existent code" do
      goal = SDG::Goal[1]

      expect(goal).to be_valid
    end

    it "is not valid without a code" do
      expect(build(:sdg_goal, code: nil)).not_to be_valid
    end

    it "is not valid with a nonexistent code" do
      [0, 18].each do |code|
        goal = SDG::Goal.where(code: code).first_or_initialize

        expect(goal).not_to be_valid
      end
    end
  end

  describe ".[]" do
    it "finds existing goals by code" do
      expect(SDG::Goal[1].code).to be 1
    end

    it "raises an exception for non-existing codes" do
      expect { SDG::Goal[100] }.to raise_exception ActiveRecord::RecordNotFound
    end
  end

  it "translates title" do
    goal = SDG::Goal[1]

    expect(goal.title).to eq "No Poverty"

    I18n.with_locale(:es) do
      expect(goal.title).to eq "Fin de la pobreza"
    end
  end

  it "translates description" do
    goal = SDG::Goal[1]

    expect(goal.description).to eq "End poverty in all its forms, everywhere."

    I18n.with_locale(:es) do
      expect(goal.description).to eq "Poner fin a la pobreza en todas sus formas en todo el mundo."
    end
  end
end
