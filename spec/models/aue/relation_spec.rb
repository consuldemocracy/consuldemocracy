require "rails_helper"

describe AUE::Relation do
  describe "Validations" do
    it "is valid with a related AUE and a relatable model" do
      relation = AUE::Relation.new(related_aue: AUE::Goal[1], relatable: create(:proposal))

      expect(relation).to be_valid
    end

    it "is not valid without a related AUE" do
      relation = AUE::Relation.new(relatable: create(:proposal))

      expect(relation).not_to be_valid
    end

    it "is not valid without a relatable model" do
      relation = AUE::Relation.new(related_aue: AUE::Goal[1])

      expect(relation).not_to be_valid
    end

    it "is not valid when a relation already exists" do
      proposal = create(:proposal)
      goal = AUE::Goal[1]

      AUE::Relation.create!(related_aue: goal, relatable: proposal)
      relation = AUE::Relation.new(related_aue: goal, relatable: proposal)

      expect(relation).not_to be_valid
    end
  end
end
