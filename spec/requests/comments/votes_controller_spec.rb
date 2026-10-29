require "rails_helper"

describe Comments::VotesController do
  describe "POST /comments/:comment_id/votes" do
    it "does not create two records with two simultaneous requests", :race_condition do
      comment = create(:debate_comment)
      user = create(:user)

      sign_in(user)
      path = comment_votes_path(comment)

      2.times.map do
        Thread.new do
          post path, xhr: true, params: { value: "yes" }
        end
      end.each(&:join)

      expect(Vote.where(voter: user, votable: comment).count).to eq 1
    end
  end
end
