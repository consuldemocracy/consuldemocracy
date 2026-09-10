require "rails_helper"

describe Management::BaseController do
  controller do
    def index
      render plain: I18n.locale
    end
  end

  describe "#verify_manager" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      Warden.test_reset!
    end

    it "redirects anonymous users to the sign in form" do
      get :index

      expect(response).to redirect_to new_user_session_path
    end

    it "denies access to regular users" do
      sign_in create(:user, :level_two)

      get :index

      expect(response).to redirect_to root_path
      expect(flash[:alert]).to eq "You do not have permission to access this page."
    end

    it "allows access to administrators" do
      sign_in create(:administrator).user

      get :index

      expect(response).to have_http_status :ok
    end

    it "allows access to managers" do
      sign_in create(:manager).user

      get :index

      expect(response).to have_http_status :ok
    end
  end

  describe "managed_user" do
    it "returns existent user with session document info if present" do
      session[:document_type] = "1"
      session[:document_number] = "333333333E"
      user = create(:user, :level_two, document_number: "333333333E")
      managed_user = subject.send(:managed_user)

      expect(managed_user).to eq user
    end

    it "returns new user if no user have the session document info" do
      session[:document_type] = "1"
      session[:document_number] = "333333333E"
      managed_user = subject.send(:managed_user)

      expect(managed_user).to be_new_record
      expect(managed_user.document_type).to eq "1"
      expect(managed_user.document_number).to eq "333333333E"
    end
  end

  describe "#switch_locale" do
    before { sign_in create(:manager).user }

    it "uses the default locale by default" do
      Setting["locales.default"] = "pt-BR"

      get :index

      expect(response.body).to eq "pt-BR"
    end

    it "uses the locale in the parameters when it's there" do
      get :index, params: { locale: :es }

      expect(response.body).to eq "es"
    end

    it "uses the locale in the session if there are no parameters" do
      get :index, params: { locale: :es }

      expect(response.body).to eq "es"

      get :index

      expect(response.body).to eq "es"
    end

    it "uses the locale in the parameters even when it's in the session" do
      get :index

      expect(response.body).to eq "en"

      get :index, params: { locale: :es }

      expect(response.body).to eq "es"
    end

    it "only accepts enabled locales" do
      Setting["locales.enabled"] = "en es fr"

      get :index, params: { locale: :es }

      expect(response.body).to eq "es"

      get :index, params: { locale: :de }

      expect(response.body).to eq "es"

      get :index, params: { locale: :fr }

      expect(response.body).to eq "fr"
    end
  end
end
