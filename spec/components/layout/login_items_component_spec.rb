require "rails_helper"

describe Layout::LoginItemsComponent do
  it "does not show the my activity link when multitenancy_management_mode is enabled" do
    allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(true)

    render_inline Layout::LoginItemsComponent.new(create(:user))

    expect(page).not_to have_content "My content"
  end
end
