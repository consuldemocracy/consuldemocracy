require 'rails_helper'

describe EmailDigest do

  describe "notifications" do

    it "returns notifications for a user" do
      user1 = create(:user)
      user2 = create(:user)

      proposal_notification = create(:proposal_notification)
      notification1 = create(:notification, notifiable: proposal_notification, user: user1)
      notification2 = create(:notification, notifiable: proposal_notification, user: user2)

      email_digest = described_class.new(user1)

      expect(email_digest.notifications).to include(notification1)
      expect(email_digest.notifications).not_to include(notification2)
    end

    it "returns only proposal notifications" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      comment = create(:comment)

      notification1 = create(:notification, notifiable: proposal_notification, user: user)
      notification2 = create(:notification, notifiable: comment,               user: user)

      email_digest = described_class.new(user)

      expect(email_digest.notifications).to include(notification1)
      expect(email_digest.notifications).not_to include(notification2)
    end

  end

  describe "pending_notifications?" do

    it "returns true when notifications have not been emailed" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      notification = create(:notification, notifiable: proposal_notification, user: user)

      email_digest = described_class.new(user)
      expect(email_digest.pending_notifications?).to be
    end

    it "returns false when notifications have been emailed" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      notification = create(:notification, notifiable: proposal_notification, user: user, emailed_at: Time.current)

      email_digest = described_class.new(user)
      expect(email_digest.pending_notifications?).not_to be
    end

    it "returns false when there are no notifications for a user" do
      user = create(:user)
      email_digest = described_class.new(user)
      expect(email_digest.pending_notifications?).not_to be
    end

  end

  describe "deliver" do

    it "delivers email if notifications pending" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      notification = create(:notification, notifiable: proposal_notification, user: user)

      reset_mailer
      email_digest = described_class.new(user)
      email_digest.deliver(Time.current)

      email = open_last_email
      expect(email).to have_subject("Proposal notifications in CONSUL")
    end

    it "does not deliver email if no notifications pending" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      create(:notification, notifiable: proposal_notification, user: user, emailed_at: Time.current)

      reset_mailer
      email_digest = described_class.new(user)
      email_digest.deliver(Time.current)

      expect(all_emails.count).to eq(0)
    end

  end

  describe "mark_as_emailed" do

    it "marks notifications as emailed" do
      user1 = create(:user)
      user2 = create(:user)

      proposal_notification = create(:proposal_notification)
      notification1 = create(:notification, notifiable: proposal_notification, user: user1)
      notification2 = create(:notification, notifiable: proposal_notification, user: user1)
      notification3 = create(:notification, notifiable: proposal_notification, user: user2)

      expect(notification1.emailed_at).not_to be
      expect(notification2.emailed_at).not_to be
      expect(notification3.emailed_at).not_to be

      email_digest = described_class.new(user1)
      email_digest.mark_as_emailed

      notification1.reload
      notification2.reload
      notification3.reload
      expect(notification1.emailed_at).to be
      expect(notification2.emailed_at).to be
      expect(notification3.emailed_at).not_to be
    end

    it "resets the failed_email_digests_count flag" do
      user1 = create(:user, failed_email_digests_count: 0)
      user2 = create(:user, failed_email_digests_count: 3)

      email_digest_1 = described_class.new(user1)
      email_digest_2 = described_class.new(user2)
      email_digest_1.mark_as_emailed
      email_digest_2.mark_as_emailed

      expect(user1.failed_email_digests_count).to eq(0)
      expect(user2.failed_email_digests_count).to eq(0)
    end

  end

  describe "#valid_email?" do

    it "returns a MatchData if email is valid" do
      user = create(:user, email: 'valid_email@email.com')

      email_digest = described_class.new(user)
      expect(email_digest.valid_email?).to be_a(MatchData)
    end

    it "returns nil if email is invalid" do
      user = create(:user, email: 'invalid_email@email..com')

      email_digest = described_class.new(user)
      expect(email_digest.valid_email?).to be(nil)
    end

    it "returns false if email does not exist" do
      user = create(:user)
      user.update_attribute(:email, nil)

      email_digest = described_class.new(user)
      expect(email_digest.valid_email?).to be(false)
    end
  end

end
