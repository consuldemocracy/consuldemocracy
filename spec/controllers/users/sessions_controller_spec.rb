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

  describe "access logs" do
    context "when feature is enabled" do
      before { allow(Rails.application.config).to receive(:authentication_logs).and_return(true) }

      it "when a sign in process succeeds it calls the authentication logger" do
        message = "The user citizen@consul.org with IP address: 0.0.0.0 successfully signed in."
        expect(AuthenticationLogger).to receive(:log).with(message)

        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}
      end

      it "when a sign in process fails it calls the authentication logger" do
        message = "The user citizen@consul.org with IP address: 0.0.0.0 failed to sign in."
        expect(AuthenticationLogger).to receive(:log).with(message)

        post :create, params: { user: { login: "citizen@consul.org", password: "wrong" }}
      end

      it "when maximum attempts is reached it tracks the user account lock" do
        allow(User).to receive(:maximum_attempts).and_return(1)
        message_1 = "The user citizen@consul.org with IP address: 0.0.0.0 failed to sign in."
        message_2 = "The user citizen@consul.org with IP address: 0.0.0.0 reached maximum attempts " \
                    "and it's temporarily locked."
        expect(AuthenticationLogger).to receive(:log).once.with(message_1)
        expect(AuthenticationLogger).to receive(:log).once.with(message_2)

        post :create, params: { user: { login: "citizen@consul.org", password: "wrong" }}
      end
    end

    context "when feature is disabled" do
      before { allow(Rails.application.config).to receive(:authentication_logs).and_return(false) }

      it "when a sign in process succeeds it does not call the authentication logger" do
        expect(AuthenticationLogger).not_to receive(:log)

        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}
      end

      it "when a sign in process fails it does not call the authentication logger" do
        expect(AuthenticationLogger).not_to receive(:log)

        post :create, params: { user: { login: "citizen@consul.org", password: "wrong" }}
      end
    end
  end
end
