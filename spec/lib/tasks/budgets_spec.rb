require "rails_helper"

describe Budget do
  let(:run_update_drafting_budgets_task) do
    Rake::Task["budgets:update_drafting_budgets"].reenable
    Rake.application.invoke_task("budgets:update_drafting_budgets")
  end

  it "does not change anything if there are not budgets in draft mode" do
    budget = create(:budget)

    expect(budget.phase).to eq "accepting"
    expect(budget.published).to be true

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.phase).to eq "accepting"
    expect(budget.published).to be true
  end

  it "changes the published attribute to false" do
    budget = create(:budget)
    budget.update_columns(phase: "drafting")

    expect(budget.published).to be true

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.published).to be false
  end

  it "changes the phase to informing phase" do
    budget = create(:budget)
    budget.update_columns(phase: "drafting")

    expect(budget.phase).to eq "drafting"

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.phase).to eq "informing"
  end
end
