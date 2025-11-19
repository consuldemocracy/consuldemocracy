require "rails_helper"

describe Admin::Settings::MapFormComponent do
  it "does not render a button to remove the marker" do
    render_inline Admin::Settings::MapFormComponent.new

    expect(page).to have_css ".map-location"
    expect(page).not_to have_button "Remove map marker"
  end
end
