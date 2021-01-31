require "rails_helper"

describe Widget::Feeds::ProcessComponent, type: :component do
  let(:process) { create(:legislation_process, sdg_goals: [SDG::Goal[1]]) }
  let(:component) { Widget::Feeds::ProcessComponent.new(process) }

  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.legislation"] = true
  end

  it "renders a card with link" do
    render_inline component

    expect(page).to have_link href: "/legislation/processes/#{process.to_param}"
  end

  it "renders a plain tag list" do
    render_inline component

    expect(page).to have_css("img[alt='1. No Poverty']")
  end
end
