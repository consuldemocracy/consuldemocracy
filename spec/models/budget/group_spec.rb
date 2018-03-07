require 'rails_helper'

describe Budget::Group do

  let(:budget) { create(:budget) }

  it_behaves_like "sluggable", updatable_slug_trait: :drafting_budget

  describe "name" do
    before do
      create(:budget_group, budget: budget, name: 'object name')
    end

    it "can be repeatead in other budget's groups" do
      expect(build(:budget_group, budget: create(:budget), name: 'object name')).to be_valid
    end

    it "must be unique among all budget's groups" do
      expect(build(:budget_group, budget: budget, name: 'object name')).not_to be_valid
    end
  end

end
