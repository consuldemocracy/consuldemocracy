require "rails_helper"

describe SDG::Review do
  describe "Validations" do
    it "is valid for any given relatable" do
      review = build(:sdg_review, :debate_review)

      expect(review).to be_valid
    end

    it "is not valid without a relatable" do
      review = build(:sdg_review, relatable: nil)

      expect(review).not_to be_valid
    end

    it "is not valid when a review for given relatable already exists" do
      relatable = create(:sdg_review, :proposal_review).relatable

      expect(build(:sdg_review, relatable: relatable)).not_to be_valid
    end
  end
end
