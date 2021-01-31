require "rails_helper"

describe Widget::Feeds::ProposalComponent, type: :component do
  let(:proposal) { create(:proposal, sdg_goals: [SDG::Goal[1]]) }
  let(:component) { Widget::Feeds::ProposalComponent.new(proposal) }

  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.proposals"] = true
  end

  it "renders a title with link" do
    render_inline component

    expect(page).to have_link proposal.title, href: "/proposals/#{proposal.to_param}"
  end

  it "renders a tag list" do
    render_inline component

    expect(page).to have_link "1. No Poverty",
                              title: "See all Citizen proposals related to goal 1",
                              href: "/proposals?advanced_search#{CGI.escape("[goal]")}=1"
  end
end
