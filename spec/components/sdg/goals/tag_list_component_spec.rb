require "rails_helper"

describe SDG::Goals::TagListComponent, type: :component do
  let(:debate) { create(:debate, sdg_goals: [SDG::Goal[1], SDG::Goal[3]]) }
  let(:component) { SDG::Goals::TagListComponent.new(debate) }

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

  it "renders links for each goal" do
    render_inline component

    expect(page).to have_selector "a", count: 2
    expect(page).to have_link "1. No Poverty",
                              title: "See all Debates related to goal 1",
                              href: "/debates?advanced_search#{CGI.escape("[goal]")}=1"
    expect(page).to have_link "3. Good Health and Well-Being",
                              title: "See all Debates related to goal 3",
                              href: "/debates?advanced_search#{CGI.escape("[goal]")}=3"
  end

  it "orders goals by code" do
    render_inline component

    expect(page.first("a")[:title]).to end_with "goal 1"
  end

  it "renders a link for more goals when out of limit" do
    component = SDG::Goals::TagListComponent.new(debate, limit: 1)

    render_inline component

    expect(page).to have_selector "a", count: 2
    expect(page).to have_link "1. No Poverty"
    expect(page).to have_link "1+",
                              title: "One more goal",
                              href: "/debates/#{debate.to_param}"
  end
end
