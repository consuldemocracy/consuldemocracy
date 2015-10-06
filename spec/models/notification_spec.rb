require 'rails_helper'

describe Notification do

  describe "#unread (scope)" do
    it "returns only unread notifications" do
      unread_notification = create :notification
      read_notification = create :notification, read: true

      unread_notifications = Notification.unread
      expect(unread_notifications.size).to be 1
      expect(unread_notifications.first).to eq unread_notification
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
    it "returns notifications with including activity, user and trackable info" do
      expect(Notification).to receive(:includes).with(activity: [:user, :trackable]).exactly(:once)
      Notification.for_render
    end
  end

  describe "#timestamp" do
    it "returns the timestamp of the trackable object" do
      comment = create :comment
      activity = create :activity, trackable: comment
      notification = create :notification, activity: activity

      expect(notification.timestamp).to eq comment.created_at
    end
  end

  describe "#mark_as_read" do
    it "set up read flag to true" do
      notification = create :notification
      expect(notification.read).to be false

      notification.mark_as_read!
      expect(notification.read).to be true
    end
  end
end
