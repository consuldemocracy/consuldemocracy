require "rails_helper"

describe Admin::Organizations::TableActionsComponent, controller: Admin::OrganizationsController do
  let(:organization) { create(:organization) }
  let(:component) { Admin::Organizations::TableActionsComponent.new(organization) }

  it "renders buttons to verify and reject when it can" do
    allow(component).to receive(:can_verify?).and_return(true)
    allow(component).to receive(:can_reject?).and_return(true)

    render_inline component

    expect(page).to have_button count: 2
    expect(page).to have_css "form[action*='verify']", exact_text: "Verify"
    expect(page).to have_css "form[action*='reject']", exact_text: "Reject"
    expect(page).to have_css "input[name='_method'][value='put']", visible: :hidden, count: 2
  end

  it "renders button to verify when it cannot reject" do
    allow(component).to receive(:can_verify?).and_return(true)
    allow(component).to receive(:can_reject?).and_return(false)

    render_inline component

    expect(page).to have_button count: 1
    expect(page).to have_button "Verify"
  end

  it "renders button to reject when it cannot verify" do
    allow(component).to receive(:can_verify?).and_return(false)
    allow(component).to receive(:can_reject?).and_return(true)

    render_inline component

    expect(page).to have_button count: 1
    expect(page).to have_button "Reject"
  end

  it "does not render any actions when it cannot verify nor reject" do
    allow(component).to receive(:can_verify?).and_return(false)
    allow(component).to receive(:can_reject?).and_return(false)

    render_inline component

    expect(page).not_to have_button
  end
end
