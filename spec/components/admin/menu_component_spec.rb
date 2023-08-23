require "rails_helper"

describe Admin::MenuComponent do
  before { sign_in(create(:administrator).user) }
  let(:component) { Admin::MenuComponent.new }

  it "only renders the multitenancy and administrators sections in multitenancy management mode" do
    allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(true)

    render_inline component

    expect(page).to have_css "#admin_menu"
    expect(page).to have_link "Multitenancy"
    expect(page).to have_link "Administrators"
    expect(page).to have_css "a", count: 2
  end
end
