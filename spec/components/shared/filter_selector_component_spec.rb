require "rails_helper"

describe Shared::FilterSelectorComponent, type: :component do
  it "renders a form with a select" do
    component = Shared::FilterSelectorComponent.new(i18n_namespace: "budgets.investments.index")
    allow(component).to receive(:url_for).and_return("/")
    allow(component).to receive(:valid_filters).and_return(["unfeasible", "winners"])
    allow(component).to receive(:current_filter).and_return(nil)

    render_inline component

    expect(page).to have_select "Filtering projects by"
    expect(page).to have_selector "form[method='get'].filter-selector select"
  end
end
