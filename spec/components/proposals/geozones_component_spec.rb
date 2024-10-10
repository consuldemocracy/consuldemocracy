require "rails_helper"

describe Proposals::GeozonesComponent do
  let(:component) { Proposals::GeozonesComponent.new() }

  it "is not rendered when there are no geozones defined" do
    render_inline component

    expect(page).not_to have_content "Districts"
  end

  it "is rendered when there are geozones defined" do
    create(:geozone)

    render_inline component

    expect(page).to have_content "Districts"
  end
end
