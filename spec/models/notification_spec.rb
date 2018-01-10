require 'rails_helper'

describe Notification do

  describe "#unread (scope)" do
    it "returns only unread notifications" do
      2.times { create :notification }
      expect(described_class.unread.size).to be 2
    end
  end

  describe "#recent (scope)" do
    it "returns notifications sorted by id descendant" do
      old_notification = create :notification
      new_notification = create :notification

      sorted_notifications = described_class.recent
      expect(sorted_notifications.size).to be 2
      expect(sorted_notifications.first).to eq new_notification
      expect(sorted_notifications.last).to eq old_notification
    end
  end

  describe "#for_render (scope)" do
    it "returns notifications including notifiable and user" do
      allow(described_class).to receive(:includes).with(:notifiable).exactly(:once)
      described_class.for_render
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
      expect(described_class.unread.size).to eq 1

      notification.mark_as_read
      expect(described_class.unread.size).to eq 0
    end
  end

  describe "#notification_action" do
    let(:notifiable) { create(:proposal) }

    it "returns correct action when someone comments on your commentable" do
      notification = create(:notification, notifiable: notifiable)

      expect(notification.notifiable_action).to eq "comments_on"
    end

    it "returns correct action when someone replies to your comment" do
      comment = create(:comment, commentable: notifiable)
      notification = create(:notification, notifiable: comment)

      expect(notification.notifiable_action).to eq "replies_to"
    end

  end

end
