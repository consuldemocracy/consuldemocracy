require "rails_helper"

describe Budget do
  let(:run_rake_task) do
    Rake::Task["budgets:set_original_heading_id"].reenable
    Rake.application.invoke_task("budgets:set_original_heading_id")
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
end
