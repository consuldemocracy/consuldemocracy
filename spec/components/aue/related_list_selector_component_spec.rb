require "rails_helper"

describe AUE::RelatedListSelectorComponent do
  let(:proposal) { create(:proposal) }
  let(:form) { ConsulFormBuilder.new(:proposal, proposal, ApplicationController.new.view_context, {}) }
  let(:component) { AUE::RelatedListSelectorComponent.new(form) }

  before do
    Setting["feature.aue"] = true
  end

  before(:each) do
    I18n.locale = :es
  end

  it "does not render when the feature is disabled" do
    Setting["feature.aue"] = false

    render_inline component

    expect(page).not_to be_rendered
  end

  it "renders related_aue_list field" do
    render_inline component

    expect(page).to have_css ".aue-related-list-selector .input"
    expect(page).to have_content "Agenda Urbana Española y Metas"
    expect(page).to have_css ".help-section"
  end
end
