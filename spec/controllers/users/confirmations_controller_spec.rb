require "rails_helper"

describe Users::ConfirmationsController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET show" do
    it "returns a 404 code with a wrong token" do
      expect do
        get :show, params: { confirmation_token: "non_existent" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    context "existent and used token" do
      render_views

      it "renders the page with an error message" do
        user = create(:user, confirmation_token: "token1")

        get :show, params: { user: user, confirmation_token: "token1" }

        expect(response).to be_successful
        expect(response.body).to include "You have already been verified"
      end
    end

    it "redirect to sign_in page with a existent and not used token" do
      user = create(:user, confirmation_token: "token1", confirmed_at: "")

      get :show, params: { user: user, confirmation_token: "token1" }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH update" do
    it "returns a 404 code with a wrong token" do
      expect do
        patch :update, params: { confirmation_token: "non_existent" }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
