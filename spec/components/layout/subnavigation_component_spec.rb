require "rails_helper"

describe Layout::SubnavigationComponent do
  it "is not rendered when multitenancy_management_mode is enabled" do
    allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(true)
    render_inline Layout::SubnavigationComponent.new

    expect(page).not_to be_rendered
  end
end
