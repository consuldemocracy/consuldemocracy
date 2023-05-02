class Shared::MapLocationComponent < ApplicationComponent
  attr_reader :investments_coordinates, :form

  def initialize(map_location, investments_coordinates: nil, form: nil)
    @map_location = map_location
    @investments_coordinates = investments_coordinates
    @form = form
  end

  def map_location
    @map_location ||= MapLocation.new
  end

  private

    def editable?
      form.present?
    end

    def latitude
      map_location.latitude.presence || Setting["map.latitude"]
    end

    def longitude
      map_location.longitude.presence || Setting["map.longitude"]
    end

    def zoom
      map_location.zoom.presence || Setting["map.zoom"]
    end

    def remove_marker_label
      t("proposals.form.map_remove_marker")
    end

    def remove_marker_link_id
      "remove-marker-link-#{dom_id(map_location)}"
    end

    def remove_marker
      tag.div class: "margin-bottom" do
        link_to remove_marker_label, "#",
          id: remove_marker_link_id,
          class: "location-map-remove-marker"
      end
    end

    def data
      {
        map: "",
        map_center_latitude: latitude,
        map_center_longitude: longitude,
        map_zoom: zoom,
        map_tiles_provider: Rails.application.secrets.map_tiles_provider,
        map_tiles_provider_attribution: Rails.application.secrets.map_tiles_provider_attribution,
        marker_editable: editable?,
        marker_remove_selector: "##{remove_marker_link_id}",
        marker_investments_coordinates: investments_coordinates,
        marker_latitude: map_location.latitude.presence,
        marker_longitude: map_location.longitude.presence
      }.merge(input_selectors)
    end

    def input_selectors
      if form
        {
          latitude_input_selector: "##{input_id(:latitude)}",
          longitude_input_selector: "##{input_id(:longitude)}",
          zoom_input_selector: "##{input_id(:zoom)}"
        }
      else
        {}
      end
    end

    def input_id(attribute)
      form.hidden_field(attribute).match(/ id="([^"]+)"/)[1]
    end
end
