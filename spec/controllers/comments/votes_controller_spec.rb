require "rails_helper"

describe Comments::VotesController do
  let(:comment) { create(:comment) }

  describe "POST create" do
    it "allows voting" do
      sign_in create(:user)

      expect do
        post :create, xhr: true, params: { comment_id: comment.id, value: "yes" }
      end.to change { comment.reload.votes_for.size }.by(1)
    end
  end
end
