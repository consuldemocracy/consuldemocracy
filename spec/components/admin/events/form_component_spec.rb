require "rails_helper"

RSpec.describe Admin::Events::FormComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:new_event) { Event.new }
  let(:persisted_event) { create(:event, name: "Existing Event") }
  let(:dummy_user) { create(:user) }

  before do
    # Keep the dummy user stub here so the nested documents component works
    allow_any_instance_of(ApplicationComponent).to receive(:current_user).and_return(dummy_user)
    allow_any_instance_of(ActionView::Base).to receive(:current_user).and_return(dummy_user)
  end

  it "renders empty fields for a new event" do
    with_controller_class(Admin::EventsController) do
      render_inline(Admin::Events::FormComponent.new(new_event))
    end

    expect(page).to have_css("form[action='#{admin_events_path}']")

    expect(page).to have_field("event[name]")
    expect(page).to have_field("event[description]")

    expected_button_text = I18n.t("events.new.submit_button", default: I18n.t("events.submit.default"))
    expect(page).to have_button(expected_button_text)
  end

  it "renders populated fields for a persisted event" do
    with_controller_class(Admin::EventsController) do
      render_inline(Admin::Events::FormComponent.new(persisted_event))
    end

    expect(page).to have_css("form[action='#{admin_event_path(persisted_event)}']")
    expect(page).to have_field("event[name]", with: "Existing Event")

    expected_button_text = I18n.t("events.edit.submit_button", default: I18n.t("events.submit.default"))
    expect(page).to have_button(expected_button_text)
  end
end
