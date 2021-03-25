require "rails_helper"

describe Admin::OrganizationsController, :admin do
  describe "PUT verify" do
    it "keeps query parameters while using protected redirects" do
      organization = create(:organization)

      get :verify, params: { id: organization, filter: "pending", host: "evil.dev" }

      expect(response).to redirect_to "/admin/organizations?filter=pending"
    end
  end

  describe "PUT reject" do
    it "keeps query parameters while using protected redirects" do
      organization = create(:organization)

      get :reject, params: { id: organization, filter: "pending", host: "evil.dev" }

      expect(response).to redirect_to "/admin/organizations?filter=pending"
    end
  end
end
