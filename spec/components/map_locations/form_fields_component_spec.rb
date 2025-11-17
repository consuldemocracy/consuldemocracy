require "rails_helper"

describe MapLocations::FormFieldsComponent do
  let(:proposal) { Proposal.new }
  let(:map_location) { MapLocation.new }
  let(:form) { ConsulFormBuilder.new(:proposal, proposal, ApplicationController.new.view_context, {}) }
  let(:component) { MapLocations::FormFieldsComponent.new(form, map_location: map_location) }

  it "is rendered when the map feature is enabled" do
    Setting["feature.map"] = true

    render_inline component

    expect(page).to be_rendered
  end

  it "is not rendered when the map feature is not enabled" do
    Setting["feature.map"] = false

    render_inline component

    expect(page).not_to be_rendered
  end
end
