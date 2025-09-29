require "rails_helper"

describe Users::ConfirmationsController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET show" do
    let(:tokens) { Devise.token_generator.generate(User, :confirmation_token) }
    let(:user) { create(:user) }

    it "returns a 404 code with a wrong token" do
      expect { get :show, params: { token: "non_existent" } }.to raise_error ActiveRecord::RecordNotFound
    end

    it "returns a 422 code with a existent and used token" do
      user.update!(confirmation_token: tokens[1], confirmed_at: nil, confirmation_sent_at: 4.days.ago)

      get :show, params: { confirmation_token: tokens[0] }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "redirect to sign_in page with a existent and not used token" do
      user.update!(confirmation_token: tokens[1], confirmed_at: nil)

      get :show, params: { user: user, confirmation_token: tokens[0] }

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
