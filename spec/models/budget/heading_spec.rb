require 'rails_helper'

describe Budget::Heading do

  let(:budget) { create(:budget) }
  let(:group) { create(:budget_group, budget: budget) }

  it_behaves_like "sluggable", updatable_slug_trait: :drafting_budget

  describe "name" do
    before do
      create(:budget_heading, group: group, name: 'object name')
    end

    it "can be repeatead in other budget's groups" do
      expect(build(:budget_heading, group: create(:budget_group), name: 'object name')).to be_valid
    end

    it "must be unique among all budget's groups" do
      expect(build(:budget_heading, group: create(:budget_group, budget: budget), name: 'object name')).not_to be_valid
    end

    it "must be unique among all it's group" do
      expect(build(:budget_heading, group: group, name: 'object name')).not_to be_valid
    end
  end

  describe "Save population" do
    it "Allows population == nil" do
      expect(create(:budget_heading, group: group, name: 'Population is nil', population: nil)).to be_valid
    end

    it "Doesn't allow population <= 0" do
      heading = create(:budget_heading, group: group, name: 'Population is > 0')

      heading.population = 0
      expect(heading).not_to be_valid

      heading.population = -10
      expect(heading).not_to be_valid

      heading.population = 10
      expect(heading).to be_valid
    end
  end

  describe "heading" do
    it "can be deleted if no budget's investments associated" do
      heading1 = create(:budget_heading, group: group, name: 'name')
      heading2 = create(:budget_heading, group: group, name: 'name 2')

      create(:budget_investment, heading: heading1)

      expect(heading1.can_be_deleted?).to eq false
      expect(heading2.can_be_deleted?).to eq true
    end
  end

end
