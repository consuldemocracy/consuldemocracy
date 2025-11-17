require "rails_helper"

describe Shared::MapLocationComponent do
  describe "remove marker button" do
    it "is not rendered when there's no form" do
      map_location = build(:map_location, proposal: Proposal.new)

      render_inline Shared::MapLocationComponent.new(map_location)

      expect(page).not_to have_button "Remove map marker"
    end

    it "is not rendered when there's no mappable" do
      map_location = build(:map_location)
      form = ConsulFormBuilder.new(:map_location, map_location, ApplicationController.new.view_context, {})

      render_inline Shared::MapLocationComponent.new(map_location, form: form)

      expect(page).not_to have_button "Remove map marker"
    end

    it "is rendered when there's a form and a mappable" do
      map_location = build(:map_location, proposal: Proposal.new)
      form = ConsulFormBuilder.new(:map_location, map_location, ApplicationController.new.view_context, {})

      render_inline Shared::MapLocationComponent.new(map_location, form: form)

      expect(page).to have_button "Remove map marker"
    end
  end

  describe "marker title" do
    it "uses the coordinates when there's a mappable" do
      map_location = build(
        :map_location,
        proposal: Proposal.new(title: "Meet me here"),
        latitude: "25.25",
        longitude: "13.14"
      )

      render_inline Shared::MapLocationComponent.new(map_location)

      expect(page).to have_css "[data-marker-title='Latitude: 25.25. Longitude: 13.14']"
    end

    it "uses the coordinates when there's no mappable" do
      map_location = build(:map_location, latitude: "25.25", longitude: "13.14")

      render_inline Shared::MapLocationComponent.new(map_location)

      expect(page).to have_css "[data-marker-title='Latitude: 25.25. Longitude: 13.14']"
    end

    it "is not present when the map location isn't available" do
      map_location = build(:map_location, latitude: "25.25", longitude: nil)

      render_inline Shared::MapLocationComponent.new(map_location)

      expect(page).not_to have_css "[data-marker-title]"
    end
  end
end
