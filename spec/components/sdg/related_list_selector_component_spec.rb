require "rails_helper"

describe SDG::RelatedListSelectorComponent, type: :component do
  let(:debate) { create(:debate) }
  let(:form) { ConsulFormBuilder.new(:debate, debate, ActionView::Base.new, {}) }
  let(:component) { SDG::RelatedListSelectorComponent.new(form) }

  it "renders sdg_related_list field" do
    render_inline component

    expect(page).to have_css ".sdg-related-list-selector .input"
    expect(page).to have_content "Sustainable Development Goals and Targets"
  end
end
