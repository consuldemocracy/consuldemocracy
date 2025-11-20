require "rails_helper"

describe Debates::VotesController do
  # Define standard vote parameters for reuse
  let(:valid_agree_params) { { vote_flag: true, vote_weight: 1 } }
  let(:valid_neutral_params) { { vote_flag: nil, vote_weight: 0 } } # Adjust based on your model logic
  let(:valid_disagree_params) { { vote_flag: false, vote_weight: 1 } }

  describe "POST create" do
    it "does not authorize unauthenticated users" do
      debate = create(:debate)

      post :create, xhr: true, params: { 
        debate_id: debate.id, 
        vote: valid_agree_params 
      }

      expect(response).to be_unauthorized
    end

    it "redirects unauthenticated users without JavaScript to the sign in page" do
      debate = create(:debate)

      post :create, params: { 
        debate_id: debate.id, 
        vote: valid_agree_params 
      }

      expect(response).to redirect_to new_user_session_path
    end

    it "redirects authenticated users without JavaScript to the same page" do
      debate = create(:debate)
      request.env["HTTP_REFERER"] = debate_path(debate)
      sign_in create(:user)

      expect do
        post :create, params: { 
          debate_id: debate.id, 
          vote: valid_agree_params 
        }
      end.to change { debate.reload.votes_for.size }.by(1)

      expect(response).to redirect_to debate_path(debate)
      expect(flash[:notice]).to eq I18n.t("flash.actions.create.vote")
    end

    it "allows creating a neutral vote" do
      debate = create(:debate)
      sign_in create(:user)

      expect do
        post :create, xhr: true, params: { 
          debate_id: debate.id, 
          vote: valid_neutral_params 
        }
      end.to change { debate.reload.votes_for.size }.by(1)
      
      # Optional: Verify the created vote has correct attributes
      vote = Vote.last
      expect(vote.vote_weight).to eq 0 # Or however you store neutral
    end

    describe "Vote with too many anonymous votes" do
      it "allows vote if user is allowed" do
        Setting["max_ratio_anon_votes_on_debates"] = 100
        debate = create(:debate)
        sign_in create(:user)

        expect do
          post :create, xhr: true, params: { 
            debate_id: debate.id, 
            vote: valid_agree_params 
          }
        end.to change { debate.reload.votes_for.size }.by(1)
      end

      it "does not allow voting if user is not allowed" do
        Setting["max_ratio_anon_votes_on_debates"] = 0
        debate = create(:debate, cached_votes_total: 1000)
        sign_in create(:user)

        expect do
          post :create, xhr: true, params: { 
            debate_id: debate.id, 
            vote: valid_agree_params 
          }
        end.not_to change { debate.reload.votes_for.size }
      end
    end
  end

  describe "PATCH update" do
    let(:user) { create(:user) }
    let(:debate) { create(:debate) }
    # Create an initial "Agree" vote
    let!(:vote) { create(:vote, votable: debate, voter: user, vote_flag: true, vote_weight: 1) }
    
    before do 
      sign_in user 
      request.env["HTTP_REFERER"] = debate_path(debate)
    end

    it "updates the vote from Agree to Neutral" do
      expect do
        patch :update, xhr: true, params: { 
          debate_id: debate.id, 
          id: vote.id, 
          vote: valid_neutral_params 
        }
      end.to change { vote.reload.vote_weight }.from(1).to(0) 
      
      expect(response).to have_http_status(:ok)
    end

    it "updates the vote from Agree to Disagree" do
      expect do
        patch :update, xhr: true, params: { 
          debate_id: debate.id, 
          id: vote.id, 
          vote: valid_disagree_params 
        }
      end.to change { vote.reload.vote_flag }.from(true).to(false)
    end

    it "redirects html requests correctly" do
      patch :update, params: { 
        debate_id: debate.id, 
        id: vote.id, 
        vote: valid_disagree_params 
      }
      
      expect(response).to redirect_to debate_path(debate)
      expect(flash[:notice]).to eq I18n.t("flash.actions.update.vote")
    end
  end

  describe "DELETE destroy" do
    let(:user) { create(:user) }
    let(:debate) { create(:debate) }
    let!(:vote) { create(:vote, votable: debate, voter: user) }
    before { sign_in user }

    it "allows undoing a vote if user is allowed" do
      expect do
        delete :destroy, xhr: true, params: { debate_id: debate.id, id: vote.id }
      end.to change { debate.reload.votes_for.size }.by(-1)
    end

    it "redirects authenticated users without JavaScript to the same page" do
      request.env["HTTP_REFERER"] = debates_path

      expect do
        delete :destroy, params: { debate_id: debate.id, id: vote.id }
      end.to change { debate.reload.votes_for.size }.by(-1)

      expect(response).to redirect_to debates_path
      expect(flash[:notice]).to eq I18n.t("flash.actions.destroy.vote")
    end
  end
end