require "rails_helper"

describe SDGManagement::Relations::IndexComponent, controller: SDGManagement::RelationsController do
  before do
    allow_any_instance_of(SDGManagement::RelationsController).to receive(:valid_filters)
      .and_return(SDGManagement::RelationsController::FILTERS)
    allow_any_instance_of(SDGManagement::RelationsController).to receive(:current_filter)
      .and_return(SDGManagement::RelationsController::FILTERS.first)
  end

  it "renders the search form" do
    component = SDGManagement::Relations::IndexComponent.new(Proposal.none.page(1))

    with_request_url("/anything") { render_inline component }

    expect(page).to have_css "form.complex"
  end
end
