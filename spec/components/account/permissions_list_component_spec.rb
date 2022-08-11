require "rails_helper"

describe Account::PermissionsListComponent do
  it "adds different classes for actions that can and cannot be performed" do
    render_inline Account::PermissionsListComponent.new(User.new)

    expect(page).to have_css "li.permission-allowed", text: "Participate in debates"
    expect(page).to have_css "li.permission-denied", text: "Support proposals"
  end
end
