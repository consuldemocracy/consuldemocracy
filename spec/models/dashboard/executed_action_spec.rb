require "rails_helper"

describe Dashboard::ExecutedAction do
  let(:proposal) { create :proposal }
  let(:action) { create :dashboard_action, request_to_administrators: true }

  it "is invalid when proposal is nil" do
    action = build(:dashboard_executed_action, proposal: nil)
    expect(action).not_to be_valid
  end

  it "is invalid when action is nil" do
    action = build(:dashboard_executed_action, action: nil)
    expect(action).not_to be_valid
  end

  it "is invalid when executed_at is nil" do
    action = build(:dashboard_executed_action, executed_at: nil)
    expect(action).not_to be_valid
  end

  it "when action has been already executed it is invalid" do
    _executed = create(:dashboard_executed_action, proposal: proposal, action: action)
    action = build(:dashboard_executed_action, proposal: proposal, action: action)
    expect(action).not_to be_valid
  end
end
