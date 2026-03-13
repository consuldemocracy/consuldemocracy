require "rails_helper"
require "cancan/matchers"

describe Abilities::Everyone do
  subject(:ability) { Ability.new(user) }

  let(:user) { nil }
  let(:debate) { create(:debate) }
  let(:proposal) { create(:proposal) }
  let(:sensemaker_job) { build(:sensemaker_job, :published) }

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

  it { should be_able_to(:read, sensemaker_job) }
  it { should_not be_able_to(:read, create(:sensemaker_job, :unpublished)) }
  it { should_not be_able_to(:manage, create(:sensemaker_job, :unpublished)) }
  it { should_not be_able_to(:publish, create(:sensemaker_job, :unpublished)) }
  it { should_not be_able_to(:unpublish, sensemaker_job) }

  it { should be_able_to(:results, create(:poll, :expired, results_enabled: true)) }
  it { should_not be_able_to(:results, create(:poll, :expired, results_enabled: false)) }
  it { should_not be_able_to(:results, create(:poll, results_enabled: true)) }
  it { should_not be_able_to(:results, create(:poll, :for_budget, :expired, results_enabled: true)) }

  it { should be_able_to(:stats, create(:poll, :expired, stats_enabled: true)) }
  it { should_not be_able_to(:stats, create(:poll, :expired, stats_enabled: false)) }
  it { should_not be_able_to(:stats, create(:poll, stats_enabled: true)) }
  it { should_not be_able_to(:stats, create(:poll, :for_budget, :expired, stats_enabled: true)) }

  it { should be_able_to(:read_results, create(:budget, :finished, results_enabled: true)) }
  it { should_not be_able_to(:read_results, create(:budget, :finished, results_enabled: false)) }
  it { should_not be_able_to(:read_results, create(:budget, :reviewing_ballots, results_enabled: true)) }

  describe "read_sensemaking (when sensemaker feature is enabled)" do
    before { Setting["feature.sensemaker"] = true }
    after { Setting["feature.sensemaker"] = nil }

    it { should be_able_to(:read_sensemaking, create(:budget, :finished, sensemaking_enabled: true)) }
    it { should_not be_able_to(:read_sensemaking, create(:budget, :finished, sensemaking_enabled: false)) }

    it {
      should_not be_able_to(:read_sensemaking, create(:budget, :reviewing_ballots, sensemaking_enabled: true))
    }
  end

  it "does not allow read_sensemaking when sensemaker feature is disabled" do
    Setting["feature.sensemaker"] = nil
    budget = create(:budget, :finished, sensemaking_enabled: true)

    expect(Ability.new(nil)).not_to be_able_to(:read_sensemaking, budget)
  end

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
