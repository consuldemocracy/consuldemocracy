require 'rails_helper'

describe Dashboard::Action do
  subject do 
    build :dashboard_action, 
          title: title, 
          description: description,
          day_offset: day_offset,
          required_supports: required_supports,
          request_to_administrators: request_to_administrators,
          action_type: action_type
  end

  let(:title) { Faker::Lorem.sentence }
  let(:description) { Faker::Lorem.sentence }
  let(:day_offset) { 0 }
  let(:required_supports) { 0 }
  let(:request_to_administrators) { true }
  let(:action_type) { 'resource' }

  it { should be_valid }

  context 'when validating title' do
    context 'and title is blank' do
      let(:title) { nil }

      it { should_not be_valid }
    end

    context 'and title is very short' do
      let(:title) { 'abc' }

      it { should_not be_valid }
    end

    context 'and title is very long' do
      let(:title) { 'a' * 81 }

      it { should_not be_valid }
    end
  end

  context 'when validating day_offset' do
    context 'and day_offset is nil' do
      let(:day_offset) { nil }

      it { should_not be_valid }
    end

    context 'and day_offset is negative' do
      let(:day_offset) { -1 }

      it { should_not be_valid }
    end

    context 'and day_offset is not an integer' do
      let(:day_offset) { 1.23 }

      it { should_not be_valid }
    end
  end

  context 'when validating required_supports' do
    context 'and required_supports is nil' do
      let(:required_supports) { nil }

      it { should_not be_valid }
    end

    context 'and required_supports is negative' do
      let(:required_supports) { -1 }

      it { should_not be_valid }
    end

    context 'and required_supports is not an integer' do
      let(:required_supports) { 1.23 }

      it { should_not be_valid }
    end
  end

  context 'when action type is nil' do
    let(:action_type) { nil }
    
    it { should_not be_valid }
  end

  context 'active_for?' do
    let(:proposal) { create(:proposal, published_at: published_at, cached_votes_up: cached_votes_up) }
    let(:published_at) { Time.current }
    let(:cached_votes_up) { Proposal.votes_needed_for_success + 100 }
    
    it { should be_active_for(proposal) }
                     
    context 'and not enough supports' do
      let(:required_supports) { cached_votes_up + 100 }

      it { should_not be_active_for(proposal) }
    end

    context 'and not passed enough time since publication' do
      let(:day_offset) { 10 }

      it { should_not be_active_for(proposal) }
    end
  end

  context 'executed_for? and requested_for?' do
    let(:proposal) { create(:proposal) }
    subject { create(:dashboard_action, :active, :admin_request, :resource) }

    it { should_not be_requested_for(proposal) }
    it { should_not be_executed_for(proposal) }

    context 'and executed action' do
      let(:executed_action) { create(:dashboard_executed_action, proposal: proposal, action: subject) }

      context 'and pending administrator task' do
        let!(:task) { create(:dashboard_administrator_task, :pending, source: executed_action) }  

        it { should be_requested_for(proposal) }
        it { should_not be_executed_for(proposal) }
      end

      context 'and solved administrator task' do
        let!(:task) { create(:dashboard_administrator_task, :done, source: executed_action) }  

        it { should be_requested_for(proposal) }
        it { should be_executed_for(proposal) }
      end
    end
  end
end

