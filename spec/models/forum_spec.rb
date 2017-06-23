require 'rails_helper'

describe Forum do
  describe 'delegated_ballots' do
    it "returns a hash with sp.id => number of delegated votes" do
      sp1 = create(:spending_proposal, :feasible)
      sp2 = create(:spending_proposal, :feasible)
      sp3 = create(:spending_proposal, :feasible)

      forum1 = create(:forum)
      forum2 = create(:forum)

      create(:user, :level_two, representative: forum1)
      create(:user, :level_two, representative: forum2)
      create(:user, :level_two, representative: forum2)

      forum1.ballot.spending_proposals << sp1
      forum2.ballot.spending_proposals << sp2

      expect(Forum.delegated_ballots).to eq({ sp1.id => 0, sp2.id => 1 })
    end
  end
end
