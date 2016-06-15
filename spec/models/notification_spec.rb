require 'rails_helper'

describe Notification do

  describe "#unread (scope)" do
    it "returns only unread notifications" do
      2.times { create :notification }
      expect(Notification.unread.size).to be 2
    end
  end

  describe "#recent (scope)" do
    it "returns notifications sorted by id descendant" do
      old_notification = create :notification
      new_notification = create :notification

      sorted_notifications = Notification.recent
      expect(sorted_notifications.size).to be 2
      expect(sorted_notifications.first).to eq new_notification
      expect(sorted_notifications.last).to eq old_notification
    end
  end

  describe "#for_render (scope)" do
    it "returns notifications including notifiable and user" do
      expect(Notification).to receive(:includes).with(:notifiable).exactly(:once)
      Notification.for_render
    end
  end

  describe "#timestamp" do
    it "returns the timestamp of the trackable object" do
      comment = create :comment
      notification = create :notification, notifiable: comment

      expect(notification.timestamp).to eq comment.created_at
    end
  end

  describe "#mark_as_read" do
    it "destroys notification" do
      notification = create :notification
      expect(Notification.unread.size).to eq 1

      notification.mark_as_read
      expect(Notification.unread.size).to eq 0
    end
  end

  describe "#notification_action" do

    context "when action was comment on a debate" do
      it "returns correct text when someone comments on your debate" do
        debate = create(:debate)
        notification = create :notification, notifiable: debate

        expect(notification.notifiable_action).to eq "comments_on"
      end
    end

    context "when action was comment on a debate" do
      it "returns correct text when someone replies to your comment" do
        debate = create(:debate)
        debate_comment = create :comment, commentable: debate
        notification = create :notification, notifiable: debate_comment

        expect(notification.notifiable_action).to eq "replies_to"
      end
    end

    context "when action was proposal notification" do
      it "returns correct text when the author created a proposal notification" do
        proposal_notification = create(:proposal_notification)
        notification = create :notification, notifiable: proposal_notification

        expect(notification.notifiable_action).to eq "proposal_notification"
      end
    end
  end

end
