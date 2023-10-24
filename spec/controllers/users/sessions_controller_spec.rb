require "rails_helper"

describe Users::SessionsController do
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let!(:user) { create(:user, email: "citizen@consul.org", password: "12345678") }

  describe "Devise lock" do
    context "when devise sign in maximum_attempts reached", :with_frozen_time do
      it "locks the user account and sends an email to the account with an unlock link" do
        allow(User).to receive(:maximum_attempts).and_return(1)

        expect do
          post :create, params: { user: { login: "citizen@consul.org", password: "wrongpassword" }}
        end.to change { user.reload.failed_attempts }.by(1)
           .and change { user.reload.locked_at }.from(nil).to(Time.current)

        expect(ActionMailer::Base.deliveries.count).to eq(1)
        body = ActionMailer::Base.deliveries.last.body
        expect(body).to have_content "Your account has been locked"
        expect(body).to have_link "Unlock my account"
      end
    end
  end
end
