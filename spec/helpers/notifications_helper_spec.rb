require 'rails_helper'

describe NotificationsHelper do

  describe "#notification_text_for" do
    let(:comment_activity) { create :activity, action: "debate_comment" }
    let(:reply_activity) { create :activity, action: "comment_reply" }

    context "when action was comment on a debate" do
      it "returns 'commented_on_your_debate' locale text" do
        notification = create :notification, activity: comment_activity
        expect(notification_text_for(notification)).to eq t("comments.notifications.commented_on_your_debate")
      end
    end

    context "when action was comment on a debate" do
      it "returns 'replied_to_your_comment' locale text" do
        notification = create :notification, activity: reply_activity
        expect(notification_text_for(notification)).to eq t("comments.notifications.replied_to_your_comment")
      end
    end
  end

  describe "#notifications_class_for" do
    let(:user) { create :user }

    context "when user doesn't have any notification" do
      it "returns class 'without_notifications'" do
        expect(notifications_class_for(user)).to eq "without_notifications"
      end
    end

    context "when user doesn't have unread notifications" do
      it "returns class 'without_notifications'" do
        notification = create :notification, user: user, read: true
        expect(notifications_class_for(user)).to eq "without_notifications"
      end
    end

    context "when user has unread notifications" do
      it "returns class 'with_notifications'" do
        notification = create :notification, user: user
        expect(notifications_class_for(user)).to eq "with_notifications"
      end
    end
  end

end
