require "rails_helper"

describe Widget::Feeds::DebateComponent, type: :component do
  let(:debate) { create(:debate, sdg_goals: [SDG::Goal[1]]) }
  let(:component) { Widget::Feeds::DebateComponent.new(debate) }

  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.debates"] = true
  end

  it "renders a title with link" do
    render_inline component

    expect(page).to have_link debate.title, href: "/debates/#{debate.to_param}"
  end

  it "renders a tag list" do
    render_inline component

    expect(page).to have_link "1. No Poverty",
                              title: "See all Debates related to goal 1",
                              href: "/debates?advanced_search#{CGI.escape("[goal]")}=1"
  end
end
