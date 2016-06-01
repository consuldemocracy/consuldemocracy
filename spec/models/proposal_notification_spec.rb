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

end
