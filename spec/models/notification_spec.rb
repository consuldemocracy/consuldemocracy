require "rails_helper"

describe Notification do

  let(:notification) { build(:notification) }

  context "validations" do

    it "should be valid" do
      expect(notification).to be_valid
    end

    it "should not be valid without a user" do
      notification.user = nil
      expect(notification).not_to be_valid
    end

  end

  context "scopes" do

    describe "#read" do
      it "returns only read notifications" do
        read_notification1 = create(:notification, :read)
        read_notification2 = create(:notification, :read)
        unread_notification = create(:notification)

        expect(described_class.read).to include read_notification1
        expect(described_class.read).to include read_notification2
        expect(described_class.read).not_to include unread_notification
      end
    end

    describe "#unread" do
      it "returns only unread notifications" do
        read_notification = create(:notification, :read)
        unread_notification1 = create(:notification)
        unread_notification2 = create(:notification)

        expect(described_class.unread).to include unread_notification1
        expect(described_class.unread).to include unread_notification2
        expect(described_class.unread).not_to include read_notification
      end
    end

    describe "#recent" do
      it "returns notifications sorted by id descendant" do
        old_notification = create :notification
        new_notification = create :notification

        sorted_notifications = described_class.recent
        expect(sorted_notifications.size).to be 2
        expect(sorted_notifications.first).to eq new_notification
        expect(sorted_notifications.last).to eq old_notification
      end
    end

    describe "#for_render" do
      it "returns notifications including notifiable and user" do
        allow(described_class).to receive(:includes).with(:notifiable).exactly(:once)
        described_class.for_render
      end
    end

  end

  describe "#mark_as_read" do
    it "destroys notification" do
      notification = create(:notification)
      expect(described_class.read.size).to eq 0
      expect(described_class.unread.size).to eq 1

      notification.mark_as_read
      expect(described_class.read.size).to eq 1
      expect(described_class.unread.size).to eq 0
    end
  end

  describe "#mark_as_unread" do
    it "destroys notification" do
      notification = create(:notification, :read)
      expect(described_class.unread.size).to eq 0
      expect(described_class.read.size).to eq 1

      notification.mark_as_unread
      expect(described_class.unread.size).to eq 1
      expect(described_class.read.size).to eq 0
    end
  end

  describe "#timestamp" do
    it "returns the timestamp of the trackable object" do
      comment = create :comment
      notification = create :notification, notifiable: comment

      expect(notification.timestamp).to eq comment.created_at
    end
  end

  describe "#existent" do
    it "returns the notifiable when there is an existent notification of that notifiable" do
      user = create(:user)
      comment = create(:comment)
      notification = create(:notification, user: user, notifiable: comment)

      expect(described_class.existent(user, comment)).to eq(notification)
    end

    it "returns nil when there are no notifications of that notifiable for a user" do
      user = create(:user)
      comment1 = create(:comment)
      comment2 = create(:comment)
      create(:notification, user: user, notifiable: comment1)

      expect(described_class.existent(user, comment2)).to eq(nil)
    end

    it "returns nil when there are notifications of a notifiable for another user" do
      user1 = create(:user)
      user2 = create(:user)
      comment = create(:comment)
      notification = create(:notification, user: user1, notifiable: comment)

      expect(described_class.existent(user2, comment)).to eq(nil)
    end
  end

  describe "#add" do
    it "creates a new notification" do
      user = create(:user)
      comment = create(:comment)

      described_class.add(user, comment)
      expect(user.notifications.count).to eq(1)
    end

    it "increments the notification counter for an unread notification of the same notifiable" do
      user = create(:user)
      comment = create(:comment)

      described_class.add(user, comment)
      described_class.add(user, comment)

      expect(user.notifications.count).to eq(1)
      expect(user.notifications.first.counter).to eq(2)
    end

    it "creates a new notification for a read notification of the same notifiable" do
      user = create(:user)
      comment = create(:comment)

      first_notification = described_class.add(user, comment)
      first_notification.update(read_at: Time.current)

      second_notification = described_class.add(user, comment)

      expect(user.notifications.count).to eq(2)
      expect(first_notification.counter).to eq(1)
      expect(second_notification.counter).to eq(1)
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
