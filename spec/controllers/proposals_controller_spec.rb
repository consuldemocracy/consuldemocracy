require 'rails_helper'

describe ProposalsController do

  describe "GET show" do

    let(:proposal) { create :proposal }

    context "when path matches" do
      it "should not redirect to real path" do
        get :show, id: proposal.id
        expect(response).to_not redirect_to proposals_path(proposal)
      end
    end

    context "when path does not match" do
      it "should redirect to real path" do
        expect(request).to receive(:path).exactly(3).times.and_return "/#{proposal.id}-something-else"
        get :show, id: proposal.id
        expect(response).to redirect_to proposal_path(proposal)
      end
    end
  end
end
