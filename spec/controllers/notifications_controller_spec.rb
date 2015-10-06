require 'rails_helper'

describe NotificationsController do

  describe "#index" do
    let(:user) { create :user }

    it "mark all notifications as read" do
      notifications = [create(:notification, user: user), create(:notification, user: user)]
      Notification.all.each do |notification|
        expect(notification.read).to be false
      end

      sign_in user
      get :index
      Notification.all.each do |notification|
        expect(notification.read).to be true
      end
    end
  end
end
