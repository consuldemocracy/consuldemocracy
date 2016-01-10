require 'rails_helper'

describe Management::ProposalsController do

  describe "GET show" do

    let(:proposal) { create :proposal }
    let(:user) { create :user, :level_two }

    context "when path matches" do
      it "should not redirect to real path" do
        sign_in user
        login_managed_user(user)
        session[:manager] = {user_key: "31415926" , date: "20151031135905", login: "JJB033"}
        session[:document_type] =  "1"
        session[:document_number] = "12345678Z"

        get :show, id: proposal.id
        expect(response).to_not redirect_to management_proposals_path(proposal)
      end
    end

    context "when path does not match" do
      it "should redirect to real path" do
        sign_in user
        login_managed_user(user)
        session[:manager] = {user_key: "31415926" , date: "20151031135905", login: "JJB033"}
        session[:document_type] =  "1"
        session[:document_number] = "12345678Z"

        expect(request).to receive(:path).exactly(2).times.and_return "/#{proposal.id}-something-else"
        get :show, id: proposal.id
        expect(response).to redirect_to management_proposal_path(proposal)
      end
    end
  end
end
