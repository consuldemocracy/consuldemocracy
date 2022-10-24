require "rails_helper"

describe Admin::BudgetPhases::ToggleEnabledComponent, controller: Admin::BaseController do
  let(:phase) { create(:budget).phases.informing }
  let(:component) { Admin::BudgetPhases::ToggleEnabledComponent.new(phase) }

  it "is pressed when the phase is enabled" do
    phase.update!(enabled: true)

    render_inline component

    expect(page).to have_button count: 1
    expect(page).to have_button exact_text: "Yes"
    expect(page).to have_button "Enable Information phase"
    expect(page).to have_css "button[aria-pressed='true']"
  end

  it "is not pressed when the phase is disabled" do
    phase.update!(enabled: false)

    render_inline component

    expect(page).to have_button count: 1
    expect(page).to have_button exact_text: "No"
    expect(page).to have_button "Enable Information phase"
    expect(page).to have_css "button[aria-pressed='false']"
  end
end
