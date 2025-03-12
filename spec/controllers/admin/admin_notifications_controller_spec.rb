require "rails_helper"

describe Admin::AdminNotificationsController, :admin do
  describe "POST deliver" do
    it "sends notifications to every recipient" do
      2.times { create(:user) }
      notification = create(:admin_notification, segment_recipient: :all_users)

      post :deliver, params: { id: notification }

      User.find_each do |user|
        expect(user.notifications.count).to eq 1
      end
    end
  end
end
