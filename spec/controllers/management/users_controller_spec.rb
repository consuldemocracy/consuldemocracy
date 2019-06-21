require "rails_helper"

describe Management::UsersController do

  describe "logout" do
    it "removes user data from the session" do
      session[:manager] = {user_key: "31415926", date: "20151031135905", login: "JJB033"}
      session[:document_type] = "1"
      session[:document_number] = "12345678Z"

      get :logout

      expect(session[:manager]).to eq(user_key: "31415926", date: "20151031135905", login: "JJB033")
      expect(session[:document_type]).to be_nil
      expect(session[:document_number]).to be_nil
      expect(response).to be_redirect
    end
  end

end