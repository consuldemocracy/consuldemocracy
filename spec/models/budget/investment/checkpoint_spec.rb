require 'rails_helper'

describe "Budget::Investment::Checkpoint" do

  describe "Validations" do
    let(:checkpoint) { build(:budget_investment_checkpoint) }

    it "should be valid" do
      expect(checkpoint).to be_valid
    end

    it "should not be valid without a title" do
      checkpoint.title = nil
      expect(checkpoint).to_not be_valid
    end

    it "should not be valid without an investment" do
      checkpoint.investment_id = nil
      expect(checkpoint).to_not be_valid
    end
  end

end
