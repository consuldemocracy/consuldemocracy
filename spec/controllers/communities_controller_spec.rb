require "rails_helper"

describe CommunitiesController do
  describe "GET show" do
    it "raises an exception accessing a community without associated communitable" do
      proposal = create(:proposal)
      community = proposal.community
      proposal.really_destroy!

      expect do
        get :show, params: { id: community.id }
      end.to raise_error(ActionController::RoutingError)
    end
  end
end
