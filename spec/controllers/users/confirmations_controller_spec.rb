require "rails_helper"

describe Users::ConfirmationsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET show" do
    it "returns a 404 code with a wrong token" do
      expect { get :show, token: "non_existent" }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
