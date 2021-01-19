require "rails_helper"

describe SDGManagement::Relations::IndexComponent, type: :component do
  before do
    allow(ViewComponent::Base).to receive(:test_controller).and_return("SDGManagement::RelationsController")
    allow_any_instance_of(SDGManagement::RelationsController).to receive(:valid_filters)
      .and_return(SDGManagement::RelationsController::FILTERS)
    allow_any_instance_of(SDGManagement::RelationsController).to receive(:current_filter)
      .and_return(SDGManagement::RelationsController::FILTERS.first)
    allow_any_instance_of(ApplicationHelper).to receive(:current_path_with_query_params)
      .and_return("/anything")
  end

  describe "#goal_options" do
    it "orders goals by code in the select" do
      component = SDGManagement::Relations::IndexComponent.new(Proposal.none.page(1))

      render_inline component
      options = page.find("#goal_code").all("option")

      expect(options[0]).to have_content "All goals"
      expect(options[1]).to have_content "1. "
      expect(options[17]).to have_content "17. "
    end
  end
end
