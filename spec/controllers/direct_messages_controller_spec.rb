require "rails_helper"

describe DirectMessagesController do
  before { sign_in(create :user, :level_two) }

  describe "GET new" do
    let!(:user) { create(:user, username: "James Jameson") }

    it "finds a user by ID and slug" do
      get :new, params: { user_id: "#{user.id}-james-jameson" }

      expect(response).to be_successful
    end

    it "does not find a user by just an ID" do
      expect do
        get :new, params: { user_id: user.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "does not find a user by just a slug" do
      expect do
        get :new, params: { user_id: "james-jameson" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "does not find a user with the wrong slug" do
      expect do
        get :new, params: { user_id: "#{user.id}-James Jameson" }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "POST create" do
    let!(:user) { create(:user, username: "James Jameson") }
    let(:message_params) { { direct_message: { title: "Hello!", message: "How are you doing?" }} }

    it "finds a user by ID and slug" do
      post :create, params: message_params.merge(user_id: "#{user.id}-james-jameson")

      expect(response).to be_successful
    end

    it "does not find a user by just an ID" do
      expect do
        post :create, params: message_params.merge(user_id: user.id)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "does not find a user by just a slug" do
      expect do
        post :create, params: message_params.merge(user_id: "james-jameson")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "does not find a user with the wrong slug" do
      expect do
        post :create, params: message_params.merge(user_id: "#{user.id}-James Jameson")
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
