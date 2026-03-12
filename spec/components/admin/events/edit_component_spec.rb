require "rails_helper"

RSpec.describe Admin::Events::EditComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:persisted_event) { create(:event) }
  let(:dummy_user) { create(:user) }

  before do
    allow_any_instance_of(ApplicationComponent).to receive(:current_user).and_return(dummy_user)
    allow_any_instance_of(ActionView::Base).to receive(:current_user).and_return(dummy_user)
  end

  it "renders the page title, back link, and form" do
    with_controller_class(Admin::EventsController) do
      render_inline(Admin::Events::EditComponent.new(persisted_event))
    end

    expected_title = I18n.t("events.edit.title", default: "Manage Event")
    expect(page).to have_css("h2", text: expected_title)

    expect(page).to have_link(href: admin_events_path)
    expect(page).to have_css("form[action='#{admin_event_path(persisted_event)}']")
  end
end
