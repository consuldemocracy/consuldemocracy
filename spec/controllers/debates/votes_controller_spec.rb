require "rails_helper"

describe Debates::VotesController do
  describe "POST create" do
    it "does not authorize unauthenticated users" do
      debate = create(:debate)

      post :create, xhr: true, params: { debate_id: debate.id, value: "yes" }

      expect(response).to be_unauthorized
    end

    it "redirects unauthenticated users without JavaScript to the sign in page" do
      debate = create(:debate)

      post :create, params: { debate_id: debate.id, value: "yes" }

      expect(response).to redirect_to new_user_session_path
    end

    it "redirects authenticated users without JavaScript to the same page" do
      debate = create(:debate)
      request.env["HTTP_REFERER"] = debate_path(debate)
      sign_in create(:user)

      expect do
        post :create, params: { debate_id: debate.id, value: "yes" }
      end.to change { debate.reload.votes_for.size }.by(1)

      expect(response).to redirect_to debate_path(debate)
      expect(flash[:notice]).to eq "Vote created successfully"
    end

    describe "Vote with too many anonymous votes" do
      it "allows vote if user is allowed" do
        Setting["max_ratio_anon_votes_on_debates"] = 100
        debate = create(:debate)
        sign_in create(:user)

        expect do
          post :create, xhr: true, params: { debate_id: debate.id, value: "yes" }
        end.to change { debate.reload.votes_for.size }.by(1)
      end

      it "does not allow voting if user is not allowed" do
        Setting["max_ratio_anon_votes_on_debates"] = 0
        debate = create(:debate, cached_votes_total: 1000)
        sign_in create(:user)

        expect do
          post :create, xhr: true, params: { debate_id: debate.id, value: "yes" }
        end.not_to change { debate.reload.votes_for.size }
      end
    end
  end

  describe "DELETE destroy" do
    let(:user) { create(:user) }
    let(:debate) { create(:debate) }
    let!(:vote) { create(:vote, votable: debate, voter: user) }
    before { sign_in user }

    it "allows undoing a vote if user is allowed" do
      expect do
        delete :destroy, xhr: true, params: { debate_id: debate.id, id: vote }
      end.to change { debate.reload.votes_for.size }.by(-1)
    end

    it "redirects authenticated users without JavaScript to the same page" do
      request.env["HTTP_REFERER"] = debates_path

      expect do
        delete :destroy, params: { debate_id: debate.id, id: vote }
      end.to change { debate.reload.votes_for.size }.by(-1)

      expect(response).to redirect_to debates_path
      expect(flash[:notice]).to eq "Vote deleted successfully"
    end
  end
end
