require "rails_helper"

describe SDG::TagListComponent, type: :component do
  let(:debate) do
    create(:debate,
            sdg_goals: [SDG::Goal[3]],
            sdg_targets: [SDG::Target[3.2], create(:sdg_local_target, code: "3.2.1")]
          )
  end
  let(:component) { SDG::TagListComponent.new(debate) }

  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.debates"] = true
  end

  it "renders tags list with links" do
    render_inline component

    expect(page).to have_link "3. Good Health and Well-Being"
    expect(page).to have_link "target 3.2"
    expect(page).to have_link "target 3.2.1"
  end

  context "when linkable is false" do
    let(:component) { SDG::TagListComponent.new(debate, linkable: false) }

    it "renders plain tags list" do
      render_inline component

      expect(page.find(".sdg-goal-icon")[:alt]).to eq "3. Good Health and Well-Being"
      expect(page).to have_content "target 3.2"
      expect(page).to have_content "target 3.2.1"
      expect(page).not_to have_link "3. Good Health and Well-Being"
      expect(page).not_to have_link "target 3.2"
      expect(page).not_to have_link "target 3.2.1"
    end
  end
end
