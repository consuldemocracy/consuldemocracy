require 'rails_helper'

describe NotificationsController do

  describe "#index" do
    let(:user) { create :user }
    let(:notification) { create :notification, user: user }

    it "assigns @notifications" do
      sign_in user

      get :index, debate: { title: 'A sample debate', description: 'this is a sample debate', terms_of_service: 1 }
      expect(assigns(:notifications)).to eq user.notifications.unread.recent.for_render
    end
  end
end
