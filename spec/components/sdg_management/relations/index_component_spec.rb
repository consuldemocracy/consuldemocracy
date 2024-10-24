require "rails_helper"

describe SDGManagement::Relations::IndexComponent, controller: SDGManagement::RelationsController do
  before do
    allow(vc_test_controller).to receive_messages(
      valid_filters: SDGManagement::RelationsController::FILTERS,
      current_filter: SDGManagement::RelationsController::FILTERS.first
    )
  end

  it "renders the search form" do
    component = SDGManagement::Relations::IndexComponent.new(Proposal.none.page(1))

    with_request_url("/anything") { render_inline component }

    expect(page).to have_css "form.complex"
  end
end
