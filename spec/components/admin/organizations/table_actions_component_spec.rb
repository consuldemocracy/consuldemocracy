require "rails_helper"

describe Admin::Organizations::TableActionsComponent, type: :component do
  let(:organization) { create(:organization) }
  let(:component) { Admin::Organizations::TableActionsComponent.new(organization) }

  it "renders links to verify and reject when it can" do
    allow(component).to receive(:can_verify?).and_return(true)
    allow(component).to receive(:can_reject?).and_return(true)

    render_inline component

    expect(page).to have_css "a", count: 2
    expect(page).to have_css "a[href*='verify'][data-method='put']", text: "Verify"
    expect(page).to have_css "a[href*='reject'][data-method='put']", text: "Reject"
  end

  it "renders link to verify when it cannot reject" do
    allow(component).to receive(:can_verify?).and_return(true)
    allow(component).to receive(:can_reject?).and_return(false)

    render_inline component

    expect(page).to have_css "a", count: 1
    expect(page).to have_link "Verify"
  end

  it "renders link to reject when it cannot verify" do
    allow(component).to receive(:can_verify?).and_return(false)
    allow(component).to receive(:can_reject?).and_return(true)

    render_inline component

    expect(page).to have_css "a", count: 1
    expect(page).to have_link "Reject"
  end

  it "does not render any actions when it cannot verify nor reject" do
    allow(component).to receive(:can_verify?).and_return(false)
    allow(component).to receive(:can_reject?).and_return(false)

    render_inline component

    expect(page).not_to have_css "a"
  end
end
