require "rails_helper"

describe Comments::VotesController do
  let(:comment) { create(:debate_comment) }

  describe "POST create" do
    it "allows voting" do
      sign_in create(:user)

      expect do
        post :create, xhr: true, params: { comment_id: comment.id, value: "yes" }
      end.to change { comment.reload.votes_for.size }.by(1)
    end

    it "redirects authenticated users without JavaScript to the same page" do
      request.env["HTTP_REFERER"] = comment_path(comment)
      sign_in create(:user)

      expect do
        post :create, params: { comment_id: comment.id, value: "yes" }
      end.to change { comment.reload.votes_for.size }.by(1)

      expect(response).to redirect_to comment_path(comment)
      expect(flash[:notice]).to eq "Vote created successfully"
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

    it "redirects authenticated users without JavaScript to the same page" do
      request.env["HTTP_REFERER"] = debate_path(comment.commentable)
      sign_in user

      expect do
        delete :destroy, params: { comment_id: comment.id, id: vote }
      end.to change { comment.reload.votes_for.size }.by(-1)

      expect(response).to redirect_to debate_path(comment.commentable)
      expect(flash[:notice]).to eq "Vote deleted successfully"
    end
  end
end
