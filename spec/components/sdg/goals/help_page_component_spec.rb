require "rails_helper"

describe SDG::Goals::HelpPageComponent do
  let(:goals) { SDG::Goal.all }
  let(:component) { SDG::Goals::HelpPageComponent.new(goals) }

  before do
    Setting["feature.sdg"] = true
  end

  it "does not render when the feature is disabled" do
    Setting["feature.sdg"] = false

    render_inline component

    expect(page).not_to be_rendered
  end

  it "renders content when the feature is enabled" do
    render_inline component

    expect(page).to have_css ".sdg-help-content"
    expect(page).to have_content SDG::Goal[1].title
    expect(page).to have_content SDG::Goal[1].description
    expect(page).to have_css "#help_tabs"
    expect(page).to have_css "#goal_1_tab"
  end
end
