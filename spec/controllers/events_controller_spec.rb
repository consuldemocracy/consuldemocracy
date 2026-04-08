require "rails_helper"

RSpec.describe EventsController do
  let!(:event) { create(:event) }

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "accepts a valid start_date param without errors" do
      get :index, params: { start_date: "2025-05-01" }
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { id: event.id }
      expect(response).to be_successful
    end
  end
end
