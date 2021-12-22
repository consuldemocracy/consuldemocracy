require "rails_helper"

describe SubscriptionsController do
  describe "GET edit" do
    it "returns a 404 code with a wrong token" do
      expect { get :edit, params: { token: "non_existent" } }.to raise_error ActiveRecord::RecordNotFound
    end

    it "doesn't allow access to anonymous users without a token" do
      get :edit, params: { token: "" }

      expect(response).to redirect_to "/"
      expect(flash[:alert]).to eq "You do not have permission to access this page."
    end

    it "shows the 'not allowed' message in the current locale" do
      get :edit, params: { token: "", locale: :es }

      expect(response).to redirect_to "/"
      expect(flash[:alert]).to eq "No tienes permiso para acceder a esta página."
    end
  end
end
