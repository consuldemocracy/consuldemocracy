require "rails_helper"

describe Management::SessionsController do
  describe "Sign in" do
    it "denies access if wrong manager credentials" do
      allow_any_instance_of(ManagerAuthenticator).to receive(:auth).and_return(false)
      get :create, params: { login: "nonexistent", clave_usuario: "wrong" }

      expect(response).to redirect_to "/"
      expect(flash[:alert]).to eq "You do not have permission to access this page."
      expect(session[:manager]).to be nil
    end

    it "redirects to management root path if authorized manager with right credentials" do
      manager = { login: "JJB033", user_key: "31415926", date: "20151031135905" }
      allow_any_instance_of(ManagerAuthenticator).to receive(:auth).and_return(manager)

      get :create, params: {
        login: "JJB033",
        clave_usuario: "31415926",
        fecha_conexion: "20151031135905"
      }
      expect(response).to be_redirect
      expect(session[:manager][:login]).to eq "JJB033"
    end

    it "redirects to management root path if user is admin" do
      user = create(:administrator).user
      sign_in user
      get :create
      expect(response).to be_redirect
      expect(session[:manager][:login]).to eq "admin_user_#{user.id}"
    end

    it "redirects to management root path if user is manager" do
      user = create(:manager).user
      sign_in user
      get :create
      expect(response).to be_redirect
      expect(session[:manager][:login]).to eq "manager_user_#{user.id}"
    end

    it "denies access if user is not admin or manager" do
      sign_in create(:user)
      get :create

      expect(response).to redirect_to "/"
      expect(flash[:alert]).to eq "You do not have permission to access this page."
      expect(session[:manager]).to be nil
    end
  end
end
