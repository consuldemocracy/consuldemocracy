require "rails_helper"

describe Milestone::Status do

  describe "Validations" do
    let(:status) { build(:milestone_status) }

    it "is valid" do
      expect(status).to be_valid
    end

    it "is not valid without a name" do
      status.name = nil
      expect(status).not_to be_valid
    end
  end
end
