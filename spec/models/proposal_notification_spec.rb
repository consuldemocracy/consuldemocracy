require 'rails_helper'

describe ProposalNotification do
  let(:notification) { build(:proposal_notification) }

  it "should be valid" do
    expect(notification).to be_valid
  end

  it "should not be valid without a title" do
    notification.title = nil
    expect(notification).to_not be_valid
  end

  it "should not be valid without a body" do
    notification.body = nil
    expect(notification).to_not be_valid
  end

  it "should not be valid without an associated proposal" do
    notification.proposal = nil
    expect(notification).to_not be_valid
  end

  describe "public_for_api scope" do
    it "returns proposal notifications" do
      proposal = create(:proposal)
      notification = create(:proposal_notification, proposal: proposal)

      expect(ProposalNotification.public_for_api).to include(notification)
    end

    it "blocks proposal notifications whose proposal is hidden" do
      proposal = create(:proposal, :hidden)
      notification = create(:proposal_notification, proposal: proposal)

      expect(ProposalNotification.public_for_api).not_to include(notification)
    end

    it "blocks proposal notifications without proposal" do
      proposal = build(:proposal_notification, proposal: nil).save!(validate: false)

      expect(ProposalNotification.public_for_api).not_to include(notification)
    end
  end

  describe "minimum interval between notifications" do

    before(:each) do
      Setting[:proposal_notification_minimum_interval_in_days] = 3
    end

    it "should not be valid if below minium interval" do
      proposal = create(:proposal)

      notification1 = create(:proposal_notification, proposal: proposal)
      notification2 = build(:proposal_notification, proposal: proposal)

      proposal.reload
      expect(notification2).to_not be_valid
    end

    it "should be valid if notifications above minium interval" do
      proposal = create(:proposal)

      notification1 = create(:proposal_notification, proposal: proposal, created_at: 4.days.ago)
      notification2 = build(:proposal_notification, proposal: proposal)

      proposal.reload
      expect(notification2).to be_valid
    end

    it "should be valid if no notifications sent" do
      notification1 = build(:proposal_notification)

      expect(notification1).to be_valid
    end

  end

end
