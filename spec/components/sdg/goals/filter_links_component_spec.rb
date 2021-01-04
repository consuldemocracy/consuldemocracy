require "rails_helper"

describe SDG::Goals::FilterLinksComponent, type: :component do
  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.debates"] = true
    Setting["sdg.process.proposals"] = true
  end

  it "renders a title" do
    component = SDG::Goals::FilterLinksComponent.new("Debate")

    render_inline component

    expect(page).to have_content "Filters by SDG"
  end

  it "renders all goals" do
    component = SDG::Goals::FilterLinksComponent.new("Proposal")

    render_inline component

    expect(page).to have_css ".sdg-goal-icon", count: 17
  end
end
