require "rails_helper"

describe Budget do
  let(:run_rake_task) do
    Rake::Task["budgets:set_published"].reenable
    Rake.application.invoke_task("budgets:set_published")
  end

  it "does not change anything if the published attribute is set" do
    budget = create(:budget, published: false, phase: "accepting")

    run_rake_task
    budget.reload

    expect(budget.phase).to eq "accepting"
    expect(budget.published).to be false
  end

  it "publishes budgets which are not in draft mode" do
    budget = create(:budget, published: nil, phase: "accepting")

    run_rake_task
    budget.reload

    expect(budget.phase).to eq "accepting"
    expect(budget.published).to be true
  end

  it "changes the published attribute to false on drafting budgets" do
    stub_const("Budget::Phase::PHASE_KINDS", ["drafting"] + Budget::Phase::PHASE_KINDS)
    budget = create(:budget, published: nil)
    budget.update_column(:phase, "drafting")
    stub_const("Budget::Phase::PHASE_KINDS", Budget::Phase::PHASE_KINDS - ["drafting"])

    run_rake_task
    budget.reload

    expect(budget.published).to be false
    expect(budget.phase).to eq "informing"
  end

  it "changes the phase to the first enabled phase" do
    budget = create(:budget, published: nil)
    budget.update_column(:phase, "drafting")
    budget.phases.informing.update!(enabled: false)

    expect(budget.phase).to eq "drafting"

    run_rake_task
    budget.reload

    expect(budget.phase).to eq "accepting"
    expect(budget.published).to be false
  end

  it "enables and select the informing phase if there are not any enabled phases" do
    budget = create(:budget, published: nil)
    budget.update_column(:phase, "drafting")
    budget.phases.each { |phase| phase.update!(enabled: false) }

    expect(budget.phase).to eq "drafting"

    run_rake_task
    budget.reload

    expect(budget.phase).to eq "informing"
    expect(budget.phases.informing.enabled).to be true
    expect(budget.published).to be false
  end
end
