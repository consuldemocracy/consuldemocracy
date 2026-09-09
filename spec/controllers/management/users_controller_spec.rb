require "rails_helper"

describe Management::UsersController do
  describe "logout" do
    it "removes user data from the session" do
      manager = create(:manager)
      sign_in(manager.user)
      session[:document_type] = "1"
      session[:document_number] = "12345678Z"

      get :logout

      expect(session[:document_type]).to be nil
      expect(session[:document_number]).to be nil
      expect(controller.send(:current_manager)).to eq manager.user
      expect(response).to redirect_to management_root_path
    end
  end
end
