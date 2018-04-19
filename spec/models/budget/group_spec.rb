require 'rails_helper'

describe Budget::Group do
  it_behaves_like "sluggable", updatable_slug_trait: :drafting_budget

  describe "Validations" do

    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }

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

    describe "max_supportable_headings" do
      it "is invalid if its not greater than 1" do
        group.max_supportable_headings = 0
        expect(group).not_to be_valid
      end
    end

    describe "max_votable_headings" do
      it "is invalid if its not greater than 1" do
        group.max_votable_headings = 0
        expect(group).not_to be_valid
      end
    end
  end
end
