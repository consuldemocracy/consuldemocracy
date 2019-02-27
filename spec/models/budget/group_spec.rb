require "rails_helper"

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
        expect(build(:budget_group, budget: create(:budget), name: "object name")).to be_valid
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

  end
end
