require "rails_helper"

describe ImagesController do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "DELETE destroy" do
    it "redirects to the referer URL" do
      image = create(:image, imageable: create(:proposal, author: user))
      request.env["HTTP_REFERER"] = "/proposals"

      delete :destroy, params: { id: image, from: "http://evil.dev" }

      expect(response).to redirect_to "/proposals"
    end
  end
end
