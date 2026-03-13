require "rails_helper"

RSpec.describe Events::IndexComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:admin_user) { create(:administrator).user }

  before do
    allow_any_instance_of(ApplicationComponent).to receive(:current_user).and_return(nil)
    allow_any_instance_of(ActionView::Base).to receive(:current_user).and_return(nil)
  end

  it "renders the layout and yields the calendar content for public users" do
    render_inline(Events::IndexComponent.new) do
      "Successfully rendered the calendar block!"
    end

    expect(page).to have_css("h2", text: I18n.t("events.calendar.title", default: "Events Calendar"))

    # Verify the block content rendered successfully
    expect(page).to have_content("Successfully rendered the calendar block!")

    # Verify the admin buttons are hidden
    expect(page).not_to have_link(I18n.t("admin.events.index.new_event"))
  end

  it "renders the admin buttons when the user is an administrator" do
    allow_any_instance_of(ApplicationComponent).to receive(:current_user).and_return(admin_user)
    allow_any_instance_of(ActionView::Base).to receive(:current_user).and_return(admin_user)

    render_inline(Events::IndexComponent.new)

    expect(page).to have_link(I18n.t("admin.events.index.new_event"), href: new_admin_event_path)
    expect(page).to have_link(I18n.t("admin.events.index.view_list", default: "View List"),
                              href: admin_events_path)
  end
end
