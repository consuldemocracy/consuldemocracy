require "rails_helper"

RSpec.describe Events::ShowComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:event) do
    create(:event,
           name: "Park Cleanup",
           description: "Bring your own gloves.",
           starts_at: 1.day.from_now,
           ends_at: 2.days.from_now,
           location: "Central Park")
  end

  let(:admin_user) { create(:administrator).user }

  before do
    # Default to a regular user
    allow_any_instance_of(ApplicationComponent).to receive(:current_user).and_return(nil)
    allow_any_instance_of(ActionView::Base).to receive(:current_user).and_return(nil)

    allow_any_instance_of(ApplicationComponent)
      .to receive(:feature?)
      .with(:allow_attached_documents)
      .and_return(false)

    allow_any_instance_of(ActionView::Base)
      .to receive(:feature?)
      .with(:allow_attached_documents)
      .and_return(false)
  end

  it "renders the event details for a public user" do
    render_inline(Events::ShowComponent.new(event))

    # Core text details
    expect(page).to have_css("h1", text: "Park Cleanup")
    expect(page).to have_content("Bring your own gloves.")
    expect(page).to have_css(".label.success", text: "Central Park")

    # Check that dates are formatted properly
    expect(page).to have_content(I18n.l(event.starts_at, format: :long))
    expect(page).to have_content(I18n.l(event.ends_at, format: :long))

    # Ensure the admin Edit button is hidden
    expect(page).not_to have_link(I18n.t("admin.actions.edit", default: "Edit Event"))
  end

  it "renders the edit button for an administrator" do
    allow_any_instance_of(ApplicationComponent).to receive(:current_user).and_return(admin_user)
    allow_any_instance_of(ActionView::Base).to receive(:current_user).and_return(admin_user)

    render_inline(Events::ShowComponent.new(event))

    # Expect the edit link to point to the correct admin route
    expect(page).to have_link(I18n.t("admin.actions.edit", default: "Edit Event"),
                              href: edit_admin_event_path(event))
  end
end
