require "rails_helper"

describe Legislation::ProposalsController do
  describe "GET new" do
    it "redirects to register path if user is not logged in" do
      get :new, params: { process_id: create(:legislation_process, :in_proposals_phase).id }

      expect(response).to redirect_to new_user_session_path
    end
  end

  describe "GET suggest" do
    render_views

    it "only suggests proposals from the current process" do
      process = create(:legislation_process)
      other_process = create(:legislation_process)
      create(:legislation_proposal, process: process, title: "Parkland in this process")
      create(:legislation_proposal, process: other_process, title: "Parkland in another process")

      sign_in create(:user)

      get :suggest, xhr: true, params: { process_id: process.id, search: "Parkland" }

      expect(response.body).to include("Parkland in this process")
      expect(response.body).not_to include("Parkland in another process")
    end
  end
end
