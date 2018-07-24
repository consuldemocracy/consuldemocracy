require 'rails_helper'

describe Dashboard::ExecutedAction do
  subject do 
    build :dashboard_executed_action, 
          proposal: proposal,
          action: action,
          executed_at: executed_at
  end

  let(:proposal) { create :proposal }
  let(:action) do 
    create :dashboard_action, request_to_administrators: request_to_administrators, link: Faker::Internet.url
  end
  let(:request_to_administrators) { false }
  let(:executed_at) { Time.current }

  it { should be_valid }

  context 'when proposal is nil' do
    let(:proposal) { nil }

    it { should_not be_valid }
  end

  context 'when action is nil' do
    let(:action) { nil }

    it { should_not be_valid }
  end

  context 'when executed_at is nil' do
    let(:executed_at) { nil }

    it { should_not be_valid }
  end

  context 'when the action sends a request to the administrators' do
    let(:request_to_administrators) { true }

    it { should be_valid }
  end

  context 'when it has been already executed' do
    let!(:executed) { create(:dashboard_executed_action, proposal: proposal, action: action) }

    it { should_not be_valid }
  end
end
