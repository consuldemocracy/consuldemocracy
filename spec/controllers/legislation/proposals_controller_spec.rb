require "rails_helper"

describe Legislation::ProposalsController do
  describe "GET new" do
    it "redirects to register path if user is not logged in" do
      get :new, params: { process_id: create(:legislation_process, :in_proposals_phase).id }

      expect(response).to redirect_to new_user_session_path
    end
  end
end
