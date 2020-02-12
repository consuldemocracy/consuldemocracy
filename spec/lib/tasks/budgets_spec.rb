require "rails_helper"

describe Budget do
  let(:run_rake_task) do
    Rake::Task["budgets:set_original_heading_id"].reenable
    Rake.application.invoke_task("budgets:set_original_heading_id")
  end
  let(:run_update_drafting_budgets_task) do
    Rake::Task["budgets:update_drafting_budgets"].reenable
    Rake.application.invoke_task("budgets:update_drafting_budgets")
  end

  it "sets attribute original_heading_id for existing investments" do
    heading = create(:budget_heading)
    investment = create(:budget_investment, heading: heading)
    investment.update!(original_heading_id: nil)

    expect(investment.original_heading_id).to equal(nil)

    run_rake_task
    investment.reload

    expect(investment.original_heading_id).to equal(heading.id)
  end

  it "does not overwrite original_heading_id when already present" do
    original_heading = create(:budget_heading)
    new_heading = create(:budget_heading)
    investment = create(:budget_investment, heading: original_heading)
    investment.update!(heading: new_heading)

    expect(investment.original_heading_id).to eq original_heading.id

    run_rake_task
    investment.reload

    expect(investment.original_heading_id).to eq original_heading.id
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

  it "changes the published attribut to false" do
    budget = create(:budget)
    budget.update_columns(phase: "drafting")

    expect(budget.published).to be true

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.published).to be false
  end

  it "changes the phase to the first enabled phase" do
    budget = create(:budget)
    budget.update_columns(phase: "drafting")
    budget.phases.informing.update!(enabled: false)

    expect(budget.phase).to eq "drafting"

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.phase).to eq "accepting"
  end

  it "enables and select the informing phase if there are not any enabled phases" do
    budget = create(:budget)
    budget.update_columns(phase: "drafting")
    budget.phases.each { |phase| phase.update!(enabled: false) }

    expect(budget.phase).to eq "drafting"

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.phase).to eq "informing"
    expect(budget.phases.informing.enabled).to be true
  end
end
