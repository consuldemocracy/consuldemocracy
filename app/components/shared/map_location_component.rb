class Shared::MapLocationComponent < ApplicationComponent
  attr_reader :investments_coordinates, :form, :geozones_data

  def initialize(map_location, investments_coordinates: nil, form: nil, geozones_data: nil)
    @map_location = map_location
    @investments_coordinates = investments_coordinates
    @form = form
    @geozones_data = geozones_data
  end

  def map_location
    @map_location ||= MapLocation.new
  end

  private

    def editable?
      form.present?
    end

    def latitude
      map_location.latitude.presence || Map.default.map_location.latitude
    end

    def longitude
      map_location.longitude.presence || Map.default.map_location.longitude
    end

    def zoom
      map_location.zoom.presence || Map.default.map_location.zoom
    end

    def remove_marker_label
      t("proposals.form.map_remove_marker")
    end

    def remove_marker_id
      "remove-marker-#{dom_id(map_location)}"
    end

    def remove_marker
      button_tag remove_marker_label,
                 id: remove_marker_id,
                 class: "map-location-remove-marker",
                 type: "button"
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
        marker_remove_selector: "##{remove_marker_id}",
        marker_investments_coordinates: investments_coordinates,
        marker_latitude: map_location.latitude.presence,
        marker_longitude: map_location.longitude.presence,
        marker_clustering: feature?("map.feature.marker_clustering"),
        geozones: geozones_data
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
