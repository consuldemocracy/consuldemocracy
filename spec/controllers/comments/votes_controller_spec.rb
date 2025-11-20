require "rails_helper"

describe Comments::VotesController do
  let(:comment) { create(:debate_comment) }
  
  # Standardized params for 3-way voting
  let(:valid_agree_params) { { vote_flag: true, vote_weight: 1 } }
  let(:valid_neutral_params) { { vote_flag: nil, vote_weight: 0 } }
  let(:valid_disagree_params) { { vote_flag: false, vote_weight: 1 } }

  describe "POST create" do
    it "allows voting (Agree)" do
      sign_in create(:user)

      expect do
        post :create, xhr: true, params: { 
          comment_id: comment.id, 
          vote: valid_agree_params 
        }
      end.to change { comment.reload.votes_for.size }.by(1)
      
      expect(response).to have_http_status(:ok)
    end

    it "allows voting (Neutral)" do
      sign_in create(:user)

      expect do
        post :create, xhr: true, params: { 
          comment_id: comment.id, 
          vote: valid_neutral_params 
        }
      end.to change { comment.reload.votes_for.size }.by(1)
      
      # Verify the weight is actually 0
      expect(Vote.last.vote_weight).to eq(0)
    end

    it "redirects authenticated users without JavaScript to the same page" do
      request.env["HTTP_REFERER"] = comment_path(comment)
      sign_in create(:user)

      expect do
        post :create, params: { 
          comment_id: comment.id, 
          vote: valid_agree_params 
        }
      end.to change { comment.reload.votes_for.size }.by(1)

      expect(response).to redirect_to comment_path(comment)
      expect(flash[:notice]).to eq I18n.t("flash.actions.create.vote")
    end
  end

  describe "PATCH update" do
    let(:user) { create(:user) }
    let!(:vote) { create(:vote, votable: comment, voter: user, vote_flag: true, vote_weight: 1) }
    
    before do 
      sign_in user
      request.env["HTTP_REFERER"] = comment_path(comment)
    end

    it "updates the vote from Agree to Neutral" do
      expect do
        patch :update, xhr: true, params: { 
          comment_id: comment.id, 
          id: vote.id, 
          vote: valid_neutral_params 
        }
      end.to change { vote.reload.vote_weight }.from(1).to(0)

      expect(response).to have_http_status(:ok)
    end

    it "updates the vote from Agree to Disagree" do
      expect do
        patch :update, xhr: true, params: { 
          comment_id: comment.id, 
          id: vote.id, 
          vote: valid_disagree_params 
        }
      end.to change { vote.reload.vote_flag }.from(true).to(false)
    end
  end

  describe "DELETE destroy" do
    let(:user) { create(:user) }
    let!(:vote) { create(:vote, votable: comment, voter: user) }

    it "redirects unidentified users to the sign in page" do
      delete :destroy, params: { comment_id: comment.id, id: vote.id }

      expect(response).to redirect_to new_user_session_path
    end

    it "allows undoing a vote" do
      sign_in user

      expect do
        delete :destroy, xhr: true, params: { comment_id: comment.id, id: vote.id }
      end.to change { comment.reload.votes_for.size }.by(-1)
      
      expect(response).to have_http_status(:ok)
    end

    it "redirects authenticated users without JavaScript to the same page" do
      # Comments usually redirect back to the parent debate or the comment anchor
      request.env["HTTP_REFERER"] = debate_path(comment.commentable)
      sign_in user

      expect do
        delete :destroy, params: { comment_id: comment.id, id: vote.id }
      end.to change { comment.reload.votes_for.size }.by(-1)

      expect(response).to redirect_to debate_path(comment.commentable)
      expect(flash[:notice]).to eq I18n.t("flash.actions.destroy.vote")
    end
  end
end