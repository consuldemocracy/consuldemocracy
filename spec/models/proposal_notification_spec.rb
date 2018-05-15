require 'rails_helper'

describe ProposalNotification do
  let(:notification) { build(:proposal_notification) }

  it "is valid" do
    expect(notification).to be_valid
  end

  it "is not valid without a title" do
    notification.title = nil
    expect(notification).not_to be_valid
  end

  it "is not valid without a body" do
    notification.body = nil
    expect(notification).not_to be_valid
  end

  it "is not valid without an associated proposal" do
    notification.proposal = nil
    expect(notification).not_to be_valid
  end

  describe "public_for_api scope" do
    it "returns proposal notifications" do
      proposal = create(:proposal)
      notification = create(:proposal_notification, proposal: proposal)

      expect(described_class.public_for_api).to include(notification)
    end

    it "blocks proposal notifications whose proposal is hidden" do
      proposal = create(:proposal, :hidden)
      notification = create(:proposal_notification, proposal: proposal)

      expect(described_class.public_for_api).not_to include(notification)
    end

    it "blocks proposal notifications without proposal" do
      proposal = build(:proposal_notification, proposal: nil).save!(validate: false)

      expect(described_class.public_for_api).not_to include(notification)
    end
  end

  describe "minimum interval between notifications" do

    before do
      Setting[:proposal_notification_minimum_interval_in_days] = 3
    end

    it "is not valid if below minium interval" do
      proposal = create(:proposal)

      notification1 = create(:proposal_notification, proposal: proposal)
      notification2 = build(:proposal_notification, proposal: proposal)

      proposal.reload
      expect(notification2).not_to be_valid
    end

    it "is valid if notifications above minium interval" do
      proposal = create(:proposal)

      notification1 = create(:proposal_notification, proposal: proposal, created_at: 4.days.ago)
      notification2 = build(:proposal_notification, proposal: proposal)

      proposal.reload
      expect(notification2).to be_valid
    end

    it "is valid if no notifications sent" do
      notification1 = build(:proposal_notification)

      expect(notification1).to be_valid
    end

  end

  describe "notifications in-app" do

    let(:notifiable) { create(model_name(described_class)) }
    let(:proposal) { notifiable.proposal }

    describe "#notification_title" do

      it "returns the proposal title" do
        notification = create(:notification, notifiable: notifiable)

        expect(notification.notifiable_title).to eq notifiable.proposal.title
      end

    end

    describe "#notification_action" do

      it "returns the correct action" do
        notification = create(:notification, notifiable: notifiable)

        expect(notification.notifiable_action).to eq "proposal_notification"
      end

    end

    describe "notifiable_available?" do

      it "returns true when the proposal is available" do
        notification = create(:notification, notifiable: notifiable)

        expect(notification.notifiable_available?).to be(true)
      end

      it "returns false when the proposal is not available" do
        notification = create(:notification, notifiable: notifiable)

        notifiable.proposal.destroy

        expect(notification.notifiable_available?).to be(false)
      end

    end

    describe "check_availability" do

      it "returns true if the resource is present, not hidden, nor retired" do
        notification = create(:notification, notifiable: notifiable)

        expect(notification.check_availability(proposal)).to be(true)
      end

      it "returns false if the resource is not present" do
        notification = create(:notification, notifiable: notifiable)

        notifiable.proposal.really_destroy!
        expect(notification.check_availability(proposal)).to be(false)
      end

      it "returns false if the resource is hidden" do
        notification = create(:notification, notifiable: notifiable)

        notifiable.proposal.hide
        expect(notification.check_availability(proposal)).to be(false)
      end

      it "returns false if the resource is retired" do
        notification = create(:notification, notifiable: notifiable)

        notifiable.proposal.update(retired_at: Time.current)
        expect(notification.check_availability(proposal)).to be(false)
      end

    end

    describe "#moderate_system_email" do
      let(:admin) { create(:administrator) }
      let(:proposal) { create(:proposal) }
      let(:proposal_notification) { build(:proposal_notification, proposal: proposal) }
      let(:notification) { create(:notification, notifiable: proposal_notification) }

      it "removes all notifications related to the proposal notification" do
        proposal_notification.moderate_system_email(admin.user)
        expect(Notification.all.count).to be(0)
      end

      it "records the moderation action in the Activity table" do
        proposal_notification.moderate_system_email(admin.user)
        expect(Activity.last.actionable_type).to eq('ProposalNotification')
      end
    end
  end
end
