require 'rails_helper'

describe NotificationsHelper do

  describe "#notification_text_for" do
    let(:debate) { create :debate }
    let(:debate_comment) { create :comment, commentable: debate }
    let(:comment_reply)  { create :comment, commentable: debate, parent: debate_comment }

    context "when action was comment on a debate" do
      it "returns correct text when someone comments on your debate" do
        notification = create :notification, notifiable: debate_comment
        expect(notification_text_for(notification)).to eq "commented on your debate"
      end
    end

    context "when action was comment on a debate" do
      it "returns correct text when someone replies to your comment" do
        notification = create :notification, notifiable: comment_reply
        expect(notification_text_for(notification)).to eq "replied to your comment on"
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
