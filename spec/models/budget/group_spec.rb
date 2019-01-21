require 'rails_helper'

describe Budget::Group do
  it_behaves_like "sluggable", updatable_slug_trait: :drafting_budget

  describe "Validations" do

    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }

    describe "name" do
      before do
        group.update(name: "object name")
      end

      it "can be repeatead in other budget's groups" do
        expect(build(:budget_group, budget: create(:budget), name: 'object name')).to be_valid
      end

      it "may be repeated for the same group and a different locale" do
        group.update(name_fr: "object name")

        expect(group.translations.last).to be_valid
      end

      it "must not be repeated for a different group in any locale" do
        group.update(name_en: "English", name_es: "Español")

        expect(build(:budget_group, budget: budget, name_en: "English")).not_to be_valid
        expect(build(:budget_group, budget: budget, name_en: "Español")).not_to be_valid
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

  describe "before_save action #strip_name" do
    it "doesn't create default translations" do
      group = create(:budget_group, name: "Group Name", budget: create(:budget))
      group.translations.destroy_all
      expect(group.translations.count).to be 0

      group.update(name_fr: "En Français")
      expect(group.translations.count).to eq(1)
    end
  end

end
