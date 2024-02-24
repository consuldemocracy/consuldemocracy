require "rails_helper"

describe SDG::RelatedListSelectorComponent do
  let(:debate) { create(:debate) }
  let(:form) { ConsulFormBuilder.new(:debate, debate, ApplicationController.new.view_context, {}) }
  let(:component) { SDG::RelatedListSelectorComponent.new(form) }

  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.debates"] = true
  end

  it "does not render when the feature is disabled" do
    Setting["feature.sdg"] = false

    render_inline component

    expect(page).not_to be_rendered
  end

  it "does not render when the SDG process feature is disabled" do
    Setting["sdg.process.debates"] = false

    render_inline component

    expect(page).not_to be_rendered
  end

  it "renders related_sdg_list field" do
    render_inline component

    expect(page).to have_css ".sdg-related-list-selector .input"
    expect(page).to have_content "Sustainable Development Goals and Targets"
    expect(page).to have_css ".help-section"
  end

  describe "#goals_and_targets" do
    it "return all goals and target with order" do
      create(:sdg_local_target, code: "1.1.1")
      goals_and_targets = component.goals_and_targets

      expect(goals_and_targets.first).to eq SDG::Goal[1]
      expect(goals_and_targets.second).to eq SDG::Target[1.1]
      expect(goals_and_targets.third).to eq SDG::LocalTarget["1.1.1"]
      expect(goals_and_targets.last).to eq SDG::Target[17.19]
    end
  end

  describe "#suggestion_tag_for" do
    it "sets suggestion tags for goals" do
      allow(component).to receive(:goals_and_targets).and_return([SDG::Goal[1]])

      render_inline component

      expect(page.find_field("Goals and Targets")["data-suggestions-list"]).to eq([{
        tag: "1. No Poverty",
        display_text: "SDG1",
        title: "No Poverty",
        value: 1
      }].to_json)
    end

    it "sets suggestion tags for global targets" do
      allow(component).to receive(:goals_and_targets).and_return([SDG::Target[1.1]])

      render_inline component

      expect(page.find_field("Goals and Targets")["data-suggestions-list"]).to eq([{
        tag: "1.1. Eradicate Extreme Poverty",
        display_text: "1.1",
        title: "By 2030, eradicate extreme poverty for all people everywhere, " \
               "currently measured as people living on less than $1.25 a day",
        value: "1.1"
      }].to_json)
    end

    it "sets suggestion tags for local targets" do
      create(:sdg_local_target, code: "1.1.1", title: "By 2030, eradicate extreme custom text")
      allow(component).to receive(:goals_and_targets).and_return([SDG::LocalTarget["1.1.1"]])

      render_inline component

      expect(page.find_field("Goals and Targets")["data-suggestions-list"]).to eq([{
        tag: "1.1.1. By 2030 eradicate extreme custom text",
        display_text: "1.1.1",
        title: "By 2030, eradicate extreme custom text",
        value: "1.1.1"
      }].to_json)
    end
  end
end
