require "rails_helper"

describe SDG::Goals::PlainTagListComponent, type: :component do
  let(:debate) { create(:debate, sdg_goals: [SDG::Goal[1], SDG::Goal[3]]) }
  let(:component) { SDG::Goals::PlainTagListComponent.new(debate) }

  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.debates"] = true
  end

  it "does not render when the feature is disabled" do
    Setting["feature.sdg"] = false

    render_inline component

    expect(page).not_to have_css "li"
  end

  it "does not render when the SDG process feature is disabled" do
    Setting["sdg.process.debates"] = false

    render_inline component

    expect(page).not_to have_css "li"
  end

  it "renders a list of goals" do
    render_inline component

    expect(page).to have_css "li", count: 2
  end

  it "renders icons for each goal" do
    render_inline component

    expect(page).to have_selector ".sdg-goal-icon", count: 2
  end

  it "orders goals by code" do
    render_inline component

    expect(page.first(".sdg-goal-icon")[:alt]).to eq "1. No Poverty"
  end

  it "renders a link for more goals when out of limit" do
    component = SDG::Goals::PlainTagListComponent.new(debate, limit: 1)

    render_inline component

    expect(page).to have_selector ".sdg-goal-icon"
    expect(page).to have_link "1+",
                              title: "One more goal",
                              href: "/debates/#{debate.to_param}"
  end
end
