require "rails_helper"

describe UsersController do
  describe "GET show" do
    let!(:user) { create(:user, username: "James Jameson") }

    it "finds a user by ID and slug" do
      get :show, params: { id: "#{user.id}-james-jameson" }

      expect(response).to be_successful
    end

    it "does not find a user by just an ID" do
      expect do
        get :show, params: { id: user.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "does not find a user by just a slug" do
      expect do
        get :show, params: { id: "james-jameson" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "does not find a user with the wrong slug" do
      expect do
        get :show, params: { id: "#{user.id}-James Jameson" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "finds users without username by ID" do
      user.erase

      get :show, params: { id: user.id }

      expect(response).to be_successful
    end
  end
end
