class Shared::MapLocationComponent < ApplicationComponent
  attr_reader :parent_class, :editable, :remove_marker_label, :investments_coordinates
  delegate :map_location_input_id, to: :helpers

  def initialize(map_location, parent_class, editable, remove_marker_label, investments_coordinates = nil)
    @map_location = map_location
    @parent_class = parent_class
    @editable = editable
    @remove_marker_label = remove_marker_label
    @investments_coordinates = investments_coordinates
  end

  def map_location
    @map_location ||= MapLocation.new
  end

  private

    def map_location_latitude
      map_location.latitude.presence || Setting["map.latitude"]
    end

    def map_location_longitude
      map_location.longitude.presence || Setting["map.longitude"]
    end

    def map_location_zoom
      map_location.zoom.presence || Setting["map.zoom"]
    end

    def map_location_remove_marker_link_id
      "remove-marker-link-#{dom_id(map_location)}"
    end

    def map_location_remove_marker
      tag.div class: "margin-bottom" do
        link_to remove_marker_label, "#",
          id: map_location_remove_marker_link_id,
          class: "js-location-map-remove-marker location-map-remove-marker"
      end
    end

    def prepare_map_settings
      options = {
        map: "",
        map_center_latitude: map_location_latitude,
        map_center_longitude: map_location_longitude,
        map_zoom: map_location_zoom,
        map_tiles_provider: Rails.application.secrets.map_tiles_provider,
        map_tiles_provider_attribution: Rails.application.secrets.map_tiles_provider_attribution,
        marker_editable: editable,
        marker_remove_selector: "##{map_location_remove_marker_link_id}",
        latitude_input_selector: "##{map_location_input_id(parent_class, "latitude")}",
        longitude_input_selector: "##{map_location_input_id(parent_class, "longitude")}",
        zoom_input_selector: "##{map_location_input_id(parent_class, "zoom")}",
        marker_investments_coordinates: investments_coordinates
      }
      options[:marker_latitude] = map_location.latitude if map_location.latitude.present?
      options[:marker_longitude] = map_location.longitude if map_location.longitude.present?
      options
    end
end
