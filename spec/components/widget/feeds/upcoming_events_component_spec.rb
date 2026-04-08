require "rails_helper"

RSpec.describe Widget::Feeds::UpcomingEventsComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:manual_event) do
    create(:event,
           name: "Community Picnic",
           event_type: "public_meeting",
           location: "Central Park")
  end

  let(:budget) { create(:budget, name: "Participatory Budget 2026") }
  let(:budget_phase) do
    phase = budget.phases.first
    phase.update!(
      name: "Accepting Projects",
      starts_at: 1.day.from_now,
      ends_at: 1.month.from_now
    )
    phase
  end

  it "renders a standard manual event with date, title, and location" do
    render_inline(Widget::Feeds::UpcomingEventsComponent.new(manual_event))

    expect(page).to have_css("strong", text: "Community Picnic")
    expect(page).to have_link("Community Picnic", href: event_path(manual_event))

    expected_date_string = manual_event.starts_at.strftime("%d %b")
    expect(page).to have_css(".label.text-uppercase", text: expected_date_string)

    expect(page).to have_css(".label.secondary", text: "Central Park")
  end

  it "renders the correct humanized type for manual events" do
    render_inline(Widget::Feeds::UpcomingEventsComponent.new(manual_event))

    # 'public_meeting' should translate/humanize properly
    expect(page).to have_css(".label.secondary",
                             text: I18n.t("events.types.public_meeting", default: "Public meeting"))
  end

  it "renders a budget phase with a combined title and anchor link" do
    render_inline(Widget::Feeds::UpcomingEventsComponent.new(budget_phase))

    expected_title = "Participatory Budget 2026: Accepting Projects"
    expected_url = budget_path(budget, anchor: "phase-#{budget_phase.id}-accepting-projects")

    expect(page).to have_css("strong", text: expected_title)
    expect(page).to have_link(expected_title, href: expected_url)
    expect(page).to have_css(".label.secondary", text: Budget.model_name.human)
  end

  it "safely handles events without a location" do
    manual_event.update!(location: nil)
    render_inline(Widget::Feeds::UpcomingEventsComponent.new(manual_event))

    expect(page).to have_css("strong", text: "Community Picnic")

    expect(page).not_to have_text("Central Park")
  end
end
