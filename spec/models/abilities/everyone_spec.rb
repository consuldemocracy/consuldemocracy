require "rails_helper"
require "cancan/matchers"

describe Abilities::Everyone do
  subject(:ability) { Ability.new(user) }

  let(:user) { nil }
  let(:debate) { create(:debate) }
  let(:proposal) { create(:proposal) }

  it { should be_able_to(:index, Debate) }
  it { should be_able_to(:show, debate) }
  it { should_not be_able_to(:edit, Debate) }
  it { should_not be_able_to(:vote, Debate) }
  it { should_not be_able_to(:flag, Debate) }
  it { should_not be_able_to(:unflag, Debate) }

  it { should be_able_to(:index, Proposal) }
  it { should be_able_to(:show, proposal) }
  it { should_not be_able_to(:edit, Proposal) }
  it { should_not be_able_to(:vote, Proposal) }
  it { should_not be_able_to(:flag, Proposal) }
  it { should_not be_able_to(:unflag, Proposal) }

  it { should be_able_to(:show, Comment) }

  it { should be_able_to(:index, Budget) }

  it { should_not be_able_to(:manage, Dashboard::Action) }
  it { should_not be_able_to(:manage, LocalCensusRecord) }
  it { should_not be_able_to(:create, LocalCensusRecords::Import) }
  it { should_not be_able_to(:show, LocalCensusRecords::Import) }

  it { should be_able_to(:results, create(:poll, :expired, results_enabled: true)) }
  it { should_not be_able_to(:results, create(:poll, :expired, results_enabled: false)) }
  it { should_not be_able_to(:results, create(:poll, :current, results_enabled: true)) }
  it { should_not be_able_to(:results, create(:poll, :for_budget, :expired, results_enabled: true)) }

  it { should be_able_to(:stats, create(:poll, :expired, stats_enabled: true)) }
  it { should_not be_able_to(:stats, create(:poll, :expired, stats_enabled: false)) }
  it { should_not be_able_to(:stats, create(:poll, :current, stats_enabled: true)) }
  it { should_not be_able_to(:stats, create(:poll, :for_budget, :expired, stats_enabled: true)) }

  it { should be_able_to(:read_results, create(:budget, :finished, results_enabled: true)) }
  it { should_not be_able_to(:read_results, create(:budget, :finished, results_enabled: false)) }
  it { should_not be_able_to(:read_results, create(:budget, :reviewing_ballots, results_enabled: true)) }

  it { should be_able_to(:read_stats, create(:budget, :valuating, stats_enabled: true)) }
  it { should_not be_able_to(:read_stats, create(:budget, :valuating, stats_enabled: false)) }
  it { should_not be_able_to(:read_stats, create(:budget, :selecting, stats_enabled: true)) }

  it { should be_able_to(:summary, create(:legislation_process, :past)) }
  it { should_not be_able_to(:summary, create(:legislation_process, :open)) }
  it { should_not be_able_to(:summary, create(:legislation_process, :past, :not_published)) }

  it { should be_able_to(:read, SDG::Goal) }
  it { should_not be_able_to(:read, SDG::Target) }
  it { should be_able_to(:read, SDG::Phase) }

  it { should_not be_able_to(:read, SDG::Manager) }
  it { should_not be_able_to(:create, SDG::Manager) }
  it { should_not be_able_to(:delete, SDG::Manager) }
end
