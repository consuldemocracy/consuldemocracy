# frozen_string_literal: true
require 'rails_helper'

describe ProposalExecutedDashboardAction do
  subject do 
    build :proposal_executed_dashboard_action, 
          proposal: proposal,
          proposal_dashboard_action: proposal_dashboard_action,
          executed_at: executed_at
  end

  let(:proposal) { create :proposal }
  let(:proposal_dashboard_action) { create :proposal_dashboard_action }
  let(:executed_at) { Time.now }

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

  context 'when it has been already executed' do
    let!(:executed) { create(:proposal_executed_dashboard_action, proposal: proposal, proposal_dashboard_action: proposal_dashboard_action) }

    it { is_expected.not_to be_valid }
  end
end
