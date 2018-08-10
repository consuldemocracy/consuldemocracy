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

  describe "voting_style" do
    it "must be of one of a valid type" do
      Budget::Vote::KINDS.each do |vk|
        expect(build(:budget_group, voting_style: vk)).to be_valid
      end
      expect(build(:budget_group, voting_style: 'something else')).not_to be_valid
    end
  end

  describe "number_votes_per_heading" do
    it "must be at least 1" do
      expect(build(:budget_group, number_votes_per_heading: 10)).to be_valid
      expect(build(:budget_group, number_votes_per_heading: -1)).not_to be_valid
      expect(build(:budget_group, number_votes_per_heading: 0)).not_to be_valid
    end
  end

end
