require "rails_helper"

describe "votes tasks" do
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }

  describe "votes:remove_duplicate_votes" do
    before { Rake::Task["votes:remove_duplicate_votes"].reenable }

    it "removes duplicate votes" do
      second_user = create(:user)
      other_debate = create(:debate)

      vote = create(:vote, voter: user, votable: debate)
      second_vote = create(:vote, voter: second_user, votable: debate)
      other_debate_vote = create(:vote, voter: user, votable: other_debate)

      attributes = { voter_id: user.id, voter_type: "User", votable_id: debate.id, votable_type: "Debate" }

      2.times { insert(:vote, attributes) }
      insert(:vote, attributes.merge(voter_id: second_user.id))

      debate.update_column(:cached_votes_up, 99)

      expect(Vote.count).to eq 6

      Rake.application.invoke_task("votes:remove_duplicate_votes")

      expect(Vote.count).to eq 3
      expect(Vote.all).to match_array [vote, second_vote, other_debate_vote]
      expect(debate.reload.cached_votes_up).to eq 2
    end

    it "removes duplicate votes on tenants" do
      create(:tenant, schema: "votes")

      Tenant.switch("votes") do
        user = create(:user)
        debate = create(:debate)

        create(:vote, voter: user, votable: debate)
        insert(:vote, voter_id: user.id, voter_type: "User", votable_id: debate.id, votable_type: "Debate")

        expect(Vote.count).to eq 2
      end

      Rake.application.invoke_task("votes:remove_duplicate_votes")

      Tenant.switch("votes") do
        expect(Vote.count).to eq 1
      end
    end
  end
end
