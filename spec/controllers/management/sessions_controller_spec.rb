require 'rails_helper'

describe Management::SessionsController do

  describe 'Sign in' do
    it "should return 404 if wrong credentials" do
      allow_any_instance_of(ManagerAuthenticator).to receive(:auth).and_return(false)
      expect { get :create, login: "nonexistent" , clave_usuario: "wrong"}.to raise_error "Not Found"
    end

    it "should redirect to management root path if right credentials" do
      manager = {login: "JJB033", user_key: "31415926" , date: "20151031135905"}
      allow_any_instance_of(ManagerAuthenticator).to receive(:auth).and_return(manager)

      get :create, login: "JJB033" , clave_usuario: "31415926", fecha_conexion: "20151031135905"
      expect(response).to be_redirect
    end
  end

  describe 'Sign out' do
    it "should destroy the session data and redirect" do
      session[:manager] = {user_key: "31415926" , date: "20151031135905", login: "JJB033"}
      session[:document_type] =  "1"
      session[:document_number] = "12345678Z"

      delete :destroy

      expect(session[:manager]).to be_nil
      expect(session[:document_type]).to be_nil
      expect(session[:document_number]).to be_nil
      expect(response).to be_redirect
    end
  end

end