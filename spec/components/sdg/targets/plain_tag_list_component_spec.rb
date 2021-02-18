require "rails_helper"

describe SDG::Targets::PlainTagListComponent, type: :component do
  let(:debate) do
    create(:debate,
           sdg_targets: [SDG::Target[1.1], SDG::Target[3.2], create(:sdg_local_target, code: "3.2.1")]
          )
  end
  let(:component) { SDG::Targets::PlainTagListComponent.new(debate) }

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

  it "renders a list of targets" do
    render_inline component

    expect(page).to have_css "li", count: 3
  end

  it "renders tags for each target" do
    render_inline component

    expect(page).to have_css "li span[data-code='1.1']", text: "target 1.1"
    expect(page).to have_css "li span[data-code='3.2']", text: "target 3.2"
    expect(page).to have_css "li span[data-code='3.2.1']", text: "target 3.2.1"
  end

  it "orders targets by code" do
    render_inline component

    expect(page.first("li").text).to eq "target 1.1"
    expect(page.all("li").last.text).to eq "target 3.2.1"
  end

  it "renders a link for more targets when out of limit" do
    component = SDG::Targets::PlainTagListComponent.new(debate, limit: 1)

    render_inline component

    expect(page).to have_css "li", text: "target 1.1"
    expect(page).to have_selector "a", count: 1
    expect(page).to have_link "2+",
      title: "2 more targets",
      href: "/debates/#{debate.to_param}"
  end
end
