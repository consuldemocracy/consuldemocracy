require "rails_helper"

describe Budget do

  let(:run_rake_task) do
    Rake.application.invoke_task("budgets:set_original_heading_id")
  end

  it "sets attribute original_heading_id for existing investments" do
    heading = create(:budget_heading)
    investment = create(:budget_investment, heading: heading)
    investment.update(original_heading_id: nil)

    expect(investment.original_heading_id).to equal(nil)

    run_rake_task
    investment.reload

    expect(investment.original_heading_id).to equal(heading.id)
  end

end
