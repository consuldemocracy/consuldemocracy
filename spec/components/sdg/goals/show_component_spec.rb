require "rails_helper"

describe SDG::Goals::ShowComponent, type: :component do
  let!(:goal_1) { SDG::Goal[1] }

  before do
    Setting["feature.sdg"] = true
  end

  it "renders a heading" do
    component = SDG::Goals::ShowComponent.new(goal_1)

    render_inline component

    expect(page).to have_css ".goal-title"
    expect(page).to have_content "No Poverty"
  end

  it "renders a long description" do
    component = SDG::Goals::ShowComponent.new(goal_1)

    render_inline component

    expect(page).to have_css "#description_goal_#{goal_1.code}"
    expect(page).to have_content "Globally, the number of people living in extreme poverty"
    expect(page).to have_css "#read_more_goal_#{goal_1.code}"
    expect(page).to have_content "Read more about No Poverty"
    expect(page).to have_css "#read_less_goal_#{goal_1.code}.hide"
  end
end
