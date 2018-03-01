require 'rails_helper'

describe Budget::Heading::Voters do

  let(:budget) { create(:budget) }
  let(:group) { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000000) }
  let(:budget_heading_voter) { create(:heading_voter) }

  describe 'Validations' do
    it "is valid" do
      expect(heading_voter).to be_valid
    end

    it "is not valid if user_id is empty" do
      heading_voter.user_id = nil
      expect(heading_voter).not_to be_valid
    end

    it "is not valid if budget_heading_id is empty" do
      heading_voter.budget_heading_id = nil
      expect(heading_voter).not_to be_valid
    end
end
