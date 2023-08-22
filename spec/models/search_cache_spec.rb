require "rails_helper"

describe SearchCache do
  describe "#calculate_tsvector" do
    it "calculates the tsv column of a record" do
      debate = create(:debate)
      debate.update_column(:tsv, nil)

      expect(debate.reload.tsv).to be_nil

      debate.calculate_tsvector

      expect(debate.reload.tsv).not_to be_nil
    end

    it "calculates the tsv column of a hidden record" do
      debate = create(:debate, :hidden)
      debate.update_column(:tsv, nil)

      expect(debate.reload.tsv).to be_nil

      debate.calculate_tsvector

      expect(debate.reload.tsv).not_to be_nil
    end
  end
end
