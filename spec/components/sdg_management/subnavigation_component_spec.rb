require "rails_helper"

describe SDGManagement::SubnavigationComponent, type: :component do
  let(:component) do
    SDGManagement::SubnavigationComponent.new(current: :goals) do
      "Tab content"
    end
  end

  it "does not run Foundation component" do
    render_inline component

    expect(page).not_to have_css "[data-tabs]"
  end

  it "renders tabs and links properly styled" do
    render_inline component

    expect(page).to have_selector "a.is-active", text: "Goals"
    expect(page).to have_selector "a:not(.is-active)", text: "Targets"
  end

  it "renders given block within active panel" do
    render_inline(component) { "Tab content" }

    expect(page.find(".tabs-panel.is-active")).to have_content("Tab content")
  end
end
