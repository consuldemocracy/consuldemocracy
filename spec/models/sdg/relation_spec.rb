require "rails_helper"

describe SDG::Relation do
  describe "Validations" do
    it "is valid with a related SDG and a relatable model" do
      relation = SDG::Relation.new(related_sdg: SDG::Goal[1], relatable: create(:proposal))

      expect(relation).to be_valid
    end

    it "is not valid without a related SDG" do
      relation = SDG::Relation.new(relatable: create(:proposal))

      expect(relation).not_to be_valid
    end

    it "is not valid without a relatable model" do
      relation = SDG::Relation.new(related_sdg: SDG::Goal[1])

      expect(relation).not_to be_valid
    end

    it "is not valid when a relation already exists" do
      proposal = create(:proposal)
      goal = SDG::Goal[1]

      SDG::Relation.create!(related_sdg: goal, relatable: proposal)
      relation = SDG::Relation.new(related_sdg: goal, relatable: proposal)

      expect(relation).not_to be_valid
    end
  end
end
