require "rails_helper"

describe TagsController do
  describe "GET suggest" do
    before do
      create(:tag, name: "Culture")
      create(:tag, name: "Health")
      create(:tag, name: "Housing")
      sign_in create(:user)
    end

    it "returns matching tag names as suggestions for term" do
      get :suggest, params: { term: "Ho" }, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("suggestions" => ["Housing"])
    end
  end
end
