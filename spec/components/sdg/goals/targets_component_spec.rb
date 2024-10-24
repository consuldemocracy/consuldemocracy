require "rails_helper"

describe SDG::Goals::TargetsComponent do
  let(:goal) { SDG::Goal[1] }
  let(:component) { SDG::Goals::TargetsComponent.new(goal) }

  before do
    Setting["feature.sdg"] = true
  end

  it "does not render when the feature is disabled" do
    Setting["feature.sdg"] = false

    render_inline component

    expect(page).not_to be_rendered
  end

  it "renders tabs panel" do
    render_inline component

    expect(page).to have_css ".sdg-goal-targets"
    expect(page).to have_css "#goal_1_targets"
    expect(page).to have_css "li", count: 2
    expect(page).to have_content "Targets"
    expect(page).to have_content "Local targets"
    expect(page).to have_css ".tabs-content"
    expect(page).to have_css "#goal_1_tab_global_targets"
  end

  it "renders code and title for each target" do
    render_inline component

    expect(page).to have_content "1.1"
    expect(page).to have_content "By 2030, eradicate extreme poverty for all people everywhere"
  end
end
