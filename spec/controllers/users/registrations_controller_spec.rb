require "rails_helper"

describe Users::RegistrationsController do

  describe "POST check_username" do

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "when username is available" do
      it "returns true with no error message" do
        get :check_username, username: "available username"

        data = JSON.parse response.body, symbolize_names: true
        expect(data[:available]).to be true
        expect(data[:message]).to eq I18n.t("devise_views.users.registrations.new.username_is_available")
      end
    end

    context "when username is not available" do
      it "returns false with an error message" do
        user = create(:user)
        get :check_username, username: user.username

        data = JSON.parse response.body, symbolize_names: true
        expect(data[:available]).to be false
        expect(data[:message]).to eq I18n.t("devise_views.users.registrations.new.username_is_not_available")
      end
    end

  end

end