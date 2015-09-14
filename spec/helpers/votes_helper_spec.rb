require 'rails_helper'

describe VotesHelper do

  describe "#voted_for?" do
    it "should return true if voted for a proposal" do
      proposal = create(:proposal)
      votes = {proposal.id => true}

      expect(voted_for?(votes, proposal)).to eq(true)
    end

    it "should return false if not voted for a proposals" do
      proposal = create(:proposal)
      votes = {proposal.id => nil}

      expect(voted_for?(votes, proposal)).to eq(false)
    end
  end

end