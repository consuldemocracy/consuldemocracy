require 'rails_helper'

describe ProposalExecutedDashboardAction do
  subject do 
    build :proposal_executed_dashboard_action, 
          proposal: proposal,
          proposal_dashboard_action: proposal_dashboard_action,
          executed_at: executed_at,
          comments: comments
  end

  let(:proposal) { create :proposal }
  let(:proposal_dashboard_action) do 
    create :proposal_dashboard_action, request_to_administrators: request_to_administrators, link: Faker::Internet.url
  end
  let(:request_to_administrators) { false }
  let(:executed_at) { Time.now }
  let(:comments) { '' }

  it { is_expected.to be_valid }

  context 'when proposal is nil' do
    let(:proposal) { nil }

    it { is_expected.not_to be_valid }
  end

  context 'when proposal_dashboard_action is nil' do
    let(:proposal_dashboard_action) { nil }

    it { is_expected.not_to be_valid }
  end

  context 'when executed_at is nil' do
    let(:executed_at) { nil }

    it { is_expected.not_to be_valid }
  end

  context 'when the action sends a request to the administrators' do
    let(:request_to_administrators) { true }

    context 'and comments are blank' do
      let(:comments) { '' }

      it { is_expected.not_to be_valid }
    end

    context 'and comments have value' do
      let(:comments) { Faker::Lorem.sentence }

      it { is_expected.to be_valid }
    end
  end

  context 'when it has been already executed' do
    let!(:executed) { create(:proposal_executed_dashboard_action, proposal: proposal, proposal_dashboard_action: proposal_dashboard_action) }

    it { is_expected.not_to be_valid }
  end
end
