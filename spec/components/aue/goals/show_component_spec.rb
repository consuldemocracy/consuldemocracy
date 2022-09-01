require "rails_helper"

describe AUE::Goals::ShowComponent do
  let!(:goal_1) { AUE::Goal[1] }

  before do
    Setting["feature.aue"] = true
  end

  it "renders a heading" do
    component = AUE::Goals::ShowComponent.new(goal_1)

    render_inline component

    expect(page).to have_css ".goal-title"
  end

  it "renders a long description" do
    component = AUE::Goals::ShowComponent.new(goal_1)

    render_inline component

    expect(page).to have_css "#description_goal_#{goal_1.code}"
    expect(page).to have_css "#read_more_goal_#{goal_1.code}"
    expect(page).to have_css "#read_less_goal_#{goal_1.code}.hide"
  end
end
