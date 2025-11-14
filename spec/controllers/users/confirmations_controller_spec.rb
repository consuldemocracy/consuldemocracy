require "rails_helper"

describe Users::ConfirmationsController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET show" do
    it "returns a 404 code with a wrong token" do
      expect { get :show, params: { token: "non_existent" } }.to raise_error ActiveRecord::RecordNotFound
    end

    it "returns a 422 code with a existent and used token" do
      user = create(:user, confirmation_token: "token1")

      get :show, params: { user: user, confirmation_token: "token1" }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "redirect to sign_in page with a existent and not used token" do
      user = create(:user, confirmation_token: "token1", confirmed_at: "")

      get :show, params: { user: user, confirmation_token: "token1" }

      expect(response).to redirect_to(new_user_session_path)
    end

    context "with newsletter_recipient" do
      let(:tokens) { Devise.token_generator.generate(User, :confirmation_token) }
      let(:user) { create(:user, confirmation_token: tokens[1], confirmed_at: nil, newsletter: false) }

      it "adopts newsletter_recipient to user" do
        create(:newsletter_recipient, :with_confirmed, email: user.email, active: true)

        get :show, params: { user: user, confirmation_token: tokens[1] }

        expect(response).to have_http_status(302)
        expect(user.reload.newsletter).to be_truthy
      end
    end
  end
end
