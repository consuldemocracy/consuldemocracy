require "rails_helper"

describe Admin::Stats::SDG::GoalComponent, type: :component do
  let(:component) { Admin::Stats::SDG::GoalComponent.new(goal: goal) }
  let(:goal) { SDG::Goal.sample }

  it "shows goal stats" do
    create_list(:poll, 2, sdg_goals: [goal])
    create_list(:proposal, 3, sdg_goals: [goal])
    create_list(:debate, 1, sdg_goals: [goal])
    create_list(:budget_investment, 2, :winner, sdg_goals: [goal], price: 1000)
    create_list(:budget_investment, 2, sdg_goals: [goal], price: 1000)

    render_inline component

    expect(page).to have_text "Proposals 3"
    expect(page).to have_text "Polls 2"
    expect(page).to have_text "Debates 1"
    expect(page).to have_text "Investment projects sent 4"
    expect(page).to have_text "Winner investment projects 2"
    expect(page).to have_text "Approved amount $2,000"
  end
end
