require "rails_helper"

describe SDGManagement::Relations::IndexComponent, type: :component, controller: SDGManagement::RelationsController do
  before do
    allow_any_instance_of(SDGManagement::RelationsController).to receive(:valid_filters)
      .and_return(SDGManagement::RelationsController::FILTERS)
    allow_any_instance_of(SDGManagement::RelationsController).to receive(:current_filter)
      .and_return(SDGManagement::RelationsController::FILTERS.first)
    allow_any_instance_of(ApplicationHelper).to receive(:current_path_with_query_params)
      .and_return("/anything")
  end

  it "renders the search form" do
    component = SDGManagement::Relations::IndexComponent.new(Proposal.none.page(1))

    render_inline component

    expect(page).to have_css "form.complex"
  end
end
