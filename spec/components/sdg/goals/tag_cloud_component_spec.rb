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

  it "renders all goals ordered by code" do
    component = SDG::Goals::TagCloudComponent.new("Proposal")

    render_inline component

    expect(page).to have_selector ".sdg-goal-icon", count: 17
    expect(page.first("a")[:title]).to end_with "goal 1"
    expect(page.all("a").last[:title]).to end_with "goal 17"
  end
end
