require 'rails_helper'

describe Users::RegistrationsController do

  describe "POST validate" do

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "Valid user details" do
      it "should return empty errors" do
        post :validate, user: { username: "username", email: "username@email.com", password: "password", password_confirmation: "password", terms_of_service: 1 }

        data = JSON.parse response.body, symbolize_names: true
        expect(data.size).to be 0
      end
    end

    context "Invalid user details" do
      it "should return errors" do
        user = create(:user)
        post :validate, user: { username: user.username, email: "", password: "password", password_confirmation: "another_password", terms_of_service: 0 }

        data = JSON.parse response.body, symbolize_names: true
        expect(data[:username].first).to eq "has already been taken"
        expect(data[:email].first).to eq "can't be blank"
        expect(data[:password]).to be nil
        expect(data[:password_confirmation].first).to eq "doesn't match Password"
        expect(data[:terms_of_service].first).to eq "must be accepted"
      end
    end

  end

end
