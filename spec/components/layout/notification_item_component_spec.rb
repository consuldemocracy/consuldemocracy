require "rails_helper"

describe Layout::NotificationItemComponent do
  it "is not rendered for anonymous users" do
    render_inline Layout::NotificationItemComponent.new(nil)

    expect(page).not_to be_rendered
  end

  it "is rendered for identified users" do
    render_inline Layout::NotificationItemComponent.new(create(:user))

    expect(page).to be_rendered
  end
end
