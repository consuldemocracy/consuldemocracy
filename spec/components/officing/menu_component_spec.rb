require "rails_helper"

describe Officing::MenuComponent do
  let(:booth) { create(:poll_booth) }
  let(:officer) { create(:poll_officer) }
  let(:component) { Officing::MenuComponent.new(voter_user: nil) }

  before do
    create(:poll_booth_assignment, booth: booth)
    sign_in(officer.user)
  end

  it "shows the validate document link when there are vote collection shifts assigned" do
    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)

    render_inline component

    expect(page).to have_content "Validate document"
    expect(page).not_to have_content "Total recounts and results"
  end

  it "shows the total recounts link when there are recount scrutinity shifts assigned" do
    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :recount_scrutiny)

    render_inline component

    expect(page).not_to have_content "Validate document"
    expect(page).to have_content "Total recounts and results"
  end

  it "does not show any links when there are no shifts assigned" do
    render_inline component

    expect(page).not_to have_content "Validate document"
    expect(page).not_to have_content "Total recounts and results"
  end
end
