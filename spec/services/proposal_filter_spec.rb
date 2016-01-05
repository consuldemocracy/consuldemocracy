require 'rails_helper'

describe ProposalFilter do
  describe "filter params" do
    before :each do
      @proposal1 = create(:proposal, scope: "city")
      @proposal2 = create(:proposal, scope: "district", district: 1)
      @proposal3 = create(:proposal, scope: "district", district: 2)
    end

    it "should filter collection based on a single filter params" do
      filter = ProposalFilter.new(filter: 'scope=district')
      expect(filter.collection).to_not include(@proposal1)
      expect(filter.collection).to include(@proposal2)
      expect(filter.collection).to include(@proposal3)
    end

    it "should filter collection based on multiple filter params" do
      filter = ProposalFilter.new(filter: 'scope=district:district=1')
      expect(filter.collection).to_not include(@proposal1)
      expect(filter.collection).to include(@proposal2)
      expect(filter.collection).to_not include(@proposal3)
    end
  end
end
