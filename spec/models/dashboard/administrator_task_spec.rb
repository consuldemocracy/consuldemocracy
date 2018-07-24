require 'rails_helper'

describe Dashboard::AdministratorTask do
  subject { build :dashboard_administrator_task, source: executed_action }
  let(:executed_action) { build :dashboard_executed_action }

  it { should be_valid }

  context 'when source is nil' do
    let(:executed_action) { nil }

    it { should_not be_valid }
  end
end

