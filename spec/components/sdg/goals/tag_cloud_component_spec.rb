require "rails_helper"

describe SDG::Goals::TagCloudComponent, type: :component do
  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.debates"] = true
    Setting["sdg.process.proposals"] = true
  end

  it "renders a title" do
    component = SDG::Goals::TagCloudComponent.new("Debate")

    render_inline component

    expect(page).to have_content "Filters by SDG"
  end

  it "renders all goals" do
    component = SDG::Goals::TagCloudComponent.new("Proposal")

    render_inline component

    expect(page).to have_css ".sdg-goal-icon", count: 17
  end
end
