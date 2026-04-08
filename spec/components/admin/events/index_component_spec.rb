require "rails_helper"

RSpec.describe Admin::Events::IndexComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:event) { create(:event, name: "Town Hall Meeting", description: "Discussing local parks.") }
  let(:paginated_events) { Kaminari.paginate_array([event]).page(1) }
  let(:empty_events) { Kaminari.paginate_array([]).page(1) }

  it "renders a list of events when they exist" do
    with_controller_class(Admin::EventsController) do
      render_inline(Admin::Events::IndexComponent.new(paginated_events))
    end

    expect(page).to have_link(I18n.t("admin.events.index.new_event"), href: new_admin_event_path)
    expect(page).to have_css("th", text: I18n.t("admin.events.event.name"))

    expect(page).to have_css("td", text: "Town Hall Meeting")
    expect(page).to have_css("td", text: "Discussing local parks.")
    expect(page).to have_link(I18n.t("admin.actions.view", default: "View"), href: event_path(event))
  end

  it "renders an empty state callout when there are no events" do
    with_controller_class(Admin::EventsController) do
      render_inline(Admin::Events::IndexComponent.new(empty_events))
    end

    expect(page).to have_css(".callout.primary", text: I18n.t("admin.events.index.no_events"))
    expect(page).not_to have_css("table")
  end
end
