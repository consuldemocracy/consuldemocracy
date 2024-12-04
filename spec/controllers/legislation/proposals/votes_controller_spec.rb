require "rails_helper"

describe Legislation::Proposals::VotesController do
  let(:legislation_process) { create(:legislation_process) }
  let(:proposal) { create(:legislation_proposal, process: legislation_process) }

  describe "POST create" do
    let(:vote_params) do
      { process_id: legislation_process.id, legislation_proposal_id: proposal.id, value: "yes" }
    end

    it "does not authorize unauthenticated users" do
      post :create, xhr: true, params: vote_params

      expect(response).to be_unauthorized
    end

    it "redirects unauthenticated users without JavaScript to the sign in page" do
      post :create, params: vote_params

      expect(response).to redirect_to new_user_session_path
    end

    it "allows vote if user is level_two_or_three_verified" do
      sign_in create(:user, :level_two)

      expect do
        post :create, xhr: true, params: vote_params
      end.to change { proposal.reload.votes_for.size }.by(1)
    end

    it "does not allow voting if user is not level_two_or_three_verified" do
      sign_in create(:user)

      expect do
        post :create, xhr: true, params: vote_params
      end.not_to change { proposal.reload.votes_for.size }
    end

    it "redirects authenticated users without JavaScript to the same page" do
      request.env["HTTP_REFERER"] = legislation_process_proposal_path(legislation_process, proposal)
      sign_in create(:user, :level_two)

      expect do
        post :create, params: vote_params
      end.to change { proposal.reload.votes_for.size }.by(1)

      expect(response).to redirect_to legislation_process_proposal_path(legislation_process, proposal)
      expect(flash[:notice]).to eq "Vote created successfully"
    end
  end

  describe "DELETE destroy" do
    let(:user) { create(:user, :level_two) }
    let!(:vote) { create(:vote, votable: proposal, voter: user) }
    let(:vote_params) do
      { process_id: legislation_process.id, legislation_proposal_id: proposal.id, id: vote }
    end

    it "allows undoing a vote" do
      sign_in user

      expect do
        delete :destroy, xhr: true, params: vote_params
      end.to change { proposal.reload.votes_for.size }.by(-1)
    end

    it "redirects authenticated users without JavaScript to the same page" do
      request.env["HTTP_REFERER"] = legislation_process_proposals_path(legislation_process)
      sign_in user

      expect do
        delete :destroy, params: vote_params
      end.to change { proposal.reload.votes_for.size }.by(-1)

      expect(response).to redirect_to legislation_process_proposals_path(legislation_process)
      expect(flash[:notice]).to eq "Vote deleted successfully"
    end
  end
end
