require "rails_helper"

describe Notification do
  let(:notification) { build(:notification) }

  context "validations" do
    it "is valid" do
      expect(notification).to be_valid
    end

    it "is not valid without a user" do
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

        expect(Notification.read).to match_array [read_notification1, read_notification2]
        expect(Notification.read).not_to include unread_notification
      end
    end

    describe "#unread" do
      it "returns only unread notifications" do
        read_notification = create(:notification, :read)
        unread_notification1 = create(:notification)
        unread_notification2 = create(:notification)

        expect(Notification.unread).to match_array [unread_notification1, unread_notification2]
        expect(Notification.unread).not_to include read_notification
      end
    end

    describe "#recent" do
      it "returns notifications sorted by id descendant" do
        old_notification = create(:notification)
        new_notification = create(:notification)

        expect(Notification.recent).to eq [new_notification, old_notification]
      end
    end

    describe "#for_render" do
      it "returns notifications including notifiable and user" do
        allow(Notification).to receive(:includes).with(:notifiable).exactly(:once)
        Notification.for_render
      end
    end
  end

  describe "#mark_as_read" do
    it "destroys notification" do
      notification = create(:notification)
      expect(Notification.read.size).to eq 0
      expect(Notification.unread.size).to eq 1

      notification.mark_as_read
      expect(Notification.read.size).to eq 1
      expect(Notification.unread.size).to eq 0
    end
  end

  describe "#mark_as_unread" do
    it "destroys notification" do
      notification = create(:notification, :read)
      expect(Notification.unread.size).to eq 0
      expect(Notification.read.size).to eq 1

      notification.mark_as_unread
      expect(Notification.unread.size).to eq 1
      expect(Notification.read.size).to eq 0
    end
  end

  describe "#timestamp" do
    it "returns the timestamp of the trackable object" do
      comment = create(:comment)
      notification = create(:notification, notifiable: comment)

      expect(notification.timestamp).to eq comment.created_at
    end
  end

  describe "#existent" do
    it "returns the notifiable when there is an existent notification of that notifiable" do
      user = create(:user)
      comment = create(:comment)
      notification = create(:notification, user: user, notifiable: comment)

      expect(Notification.existent(user, comment)).to eq(notification)
    end

    it "returns nil when there are no notifications of that notifiable for a user" do
      user = create(:user)
      comment1 = create(:comment)
      comment2 = create(:comment)

      create(:notification, user: user, notifiable: comment1)

      expect(Notification.existent(user, comment2)).to be nil
    end

    it "returns nil when there are notifications of a notifiable for another user" do
      user1 = create(:user)
      user2 = create(:user)
      comment = create(:comment)

      create(:notification, user: user1, notifiable: comment)

      expect(Notification.existent(user2, comment)).to be nil
    end
  end

  describe "#add" do
    it "creates a new notification" do
      user = create(:user)
      comment = create(:comment)

      Notification.add(user, comment)
      expect(user.notifications.count).to eq(1)
    end

    it "increments the notification counter for an unread notification of the same notifiable" do
      user = create(:user)
      comment = create(:comment)

      Notification.add(user, comment)
      Notification.add(user, comment)

      expect(user.notifications.count).to eq(1)
      expect(user.notifications.first.counter).to eq(2)
    end

    it "creates a new notification for a read notification of the same notifiable" do
      user = create(:user)
      comment = create(:comment)

      first_notification = Notification.add(user, comment)
      first_notification.update!(read_at: Time.current)

      second_notification = Notification.add(user, comment)

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

  describe ".send_pending", :delay_jobs do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }
    let!(:proposal_notification) { create(:proposal_notification) }

    before do
      create(:notification, notifiable: proposal_notification, user: user1)
      create(:notification, notifiable: proposal_notification, user: user2)
      create(:notification, notifiable: proposal_notification, user: user3)
      reset_mailer
    end

    it "sends pending proposal notifications" do
      Setting["org_name"] = "CONSUL"
      Delayed::Worker.delay_jobs = false
      Notification.send_pending

      email = open_last_email
      expect(email).to have_subject "Proposal notifications in CONSUL"
    end

    it "sends emails in batches" do
      Notification.send_pending

      expect(Delayed::Job.count).to eq 3
    end

    it "sends batches in time intervals" do
      allow(Notification).to receive_messages(
        batch_size: 1,
        batch_interval: 1.second,
        first_batch_run_at: Time.current
      )

      remove_users_without_pending_notifications

      Notification.send_pending

      now = Notification.first_batch_run_at

      first_batch_run_at  = now.change(usec: 0)
      second_batch_run_at = (now + 1.second).change(usec: 0)
      third_batch_run_at  = (now + 2.seconds).change(usec: 0)

      expect(Delayed::Job.count).to eq 3
      expect(Delayed::Job.first.run_at.change(usec: 0)).to eq first_batch_run_at
      expect(Delayed::Job.second.run_at.change(usec: 0)).to eq second_batch_run_at
      expect(Delayed::Job.third.run_at.change(usec: 0)).to eq third_batch_run_at
    end
  end

  def remove_users_without_pending_notifications
    users_without_notifications.each(&:destroy)
  end

  def users_without_notifications
    User.select do |user|
      user.notifications.not_emailed.where(notifiable_type: "ProposalNotification").blank?
    end
  end
end
