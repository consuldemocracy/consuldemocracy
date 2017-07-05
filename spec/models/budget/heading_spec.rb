require 'rails_helper'

describe Budget::Heading do

  it_behaves_like "sluggable"

  let(:budget) { create(:budget) }
  let(:group) { create(:budget_group, budget: budget) }

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

end
