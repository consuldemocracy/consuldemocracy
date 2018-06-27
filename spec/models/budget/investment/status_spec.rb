require 'rails_helper'

describe Budget::Investment::Status do

  describe "Validations" do
    let(:status) { build(:budget_investment_status) }

    it "is valid" do
      expect(status).to be_valid
    end

    it "is not valid without a name" do
      status.name = nil
      expect(status).not_to be_valid
    end
  end
end
