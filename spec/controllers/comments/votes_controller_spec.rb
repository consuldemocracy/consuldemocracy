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

  describe "DELETE destroy" do
    let(:user) { create(:user) }
    let!(:vote) { create(:vote, votable: comment, voter: user) }

    it "redirects unidentified users to the sign in page" do
      delete :destroy, params: { comment_id: comment.id, id: vote }

      expect(response).to redirect_to new_user_session_path
    end

    it "allows undoing a vote" do
      sign_in user

      expect do
        delete :destroy, xhr: true, params: { comment_id: comment.id, id: vote }
      end.to change { comment.reload.votes_for.size }.by(-1)
    end
  end
end
