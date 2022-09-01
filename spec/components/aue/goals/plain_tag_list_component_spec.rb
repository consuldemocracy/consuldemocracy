require "rails_helper"

describe AUE::Goals::PlainTagListComponent do
  let(:proposal) { create(:proposal, aue_goals: [AUE::Goal[1], AUE::Goal[3]]) }
  let(:component) { AUE::Goals::PlainTagListComponent.new(proposal) }

  before do
    Setting["feature.aue"] = true
  end

  it "does not render when the feature is disabled" do
    Setting["feature.aue"] = false

    render_inline component

    expect(page).not_to be_rendered
  end

  it "renders a list of goals" do
    render_inline component

    expect(page).to have_css "li", count: 2
  end

  it "renders icons for each goal" do
    render_inline component

    expect(page).to have_selector ".aue-goal-icon", count: 2
  end

  it "renders a link for more goals when out of limit" do
    component = AUE::Goals::PlainTagListComponent.new(proposal, limit: 1)

    render_inline component

    expect(page).to have_selector ".aue-goal-icon"
    expect(page).to have_link "1+", href: "/proposals/#{proposal.to_param}"
  end
end
