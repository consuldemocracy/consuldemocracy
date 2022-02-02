require "rails_helper"

describe "Migration tasks" do
  describe "migrate_map_location_settings" do
    let(:run_rake_task) do
      Rake::Task["migrations:migrate_map_location_settings"].reenable
      Rake.application.invoke_task("migrations:migrate_map_location_settings")
    end
    let(:default_latitude)  { MapLocation.default_latitude }
    let(:default_longitude) { MapLocation.default_longitude }
    let(:default_zoom)      { MapLocation.default_zoom }

    it "copies the all the location data from settings to the new model" do
      Setting["map.latitude"] = latitude = -10
      Setting["map.longitude"] = longitude = 20
      Setting["map.zoom"] = zoom = 8

      run_rake_task

      expect(Map.default.map_location.latitude).not_to eq default_latitude
      expect(Map.default.map_location.longitude).not_to eq default_longitude
      expect(Map.default.map_location.zoom).not_to eq default_zoom

      expect(Map.default.map_location.latitude).to eq latitude.to_f
      expect(Map.default.map_location.longitude).to eq longitude.to_f
      expect(Map.default.map_location.zoom).to eq zoom.to_i
    end

    it "copies only the latitude location data from settings to the new model" do
      Setting["map.latitude"] = latitude = -10

      run_rake_task

      expect(Map.default.map_location.latitude).not_to eq default_latitude

      expect(Map.default.map_location.latitude).to eq latitude.to_f
      expect(Map.default.map_location.longitude).to eq default_longitude
      expect(Map.default.map_location.zoom).to eq default_zoom
    end

    it "copies only the longitude location data from settings to the new model" do
      Setting["map.longitude"] = longitude = 20

      run_rake_task

      expect(Map.default.map_location.longitude).not_to eq default_longitude

      expect(Map.default.map_location.latitude).to eq default_latitude
      expect(Map.default.map_location.longitude).to eq longitude.to_f
      expect(Map.default.map_location.zoom).to eq default_zoom
    end

    it "copies only the zoom location data from settings to the new model" do
      Setting["map.zoom"] = zoom = 8

      run_rake_task

      expect(Map.default.map_location.zoom).not_to eq default_zoom

      expect(Map.default.map_location.latitude).to eq default_latitude
      expect(Map.default.map_location.longitude).to eq default_longitude
      expect(Map.default.map_location.zoom).to eq zoom.to_i
    end

    it "deletes the location settings after running the task" do
      Setting["map.latitude"] = -10
      Setting["map.longitude"] = 20
      Setting["map.zoom"] = 8

      run_rake_task

      expect(Setting["map.latitude"]).to be nil
      expect(Setting["map.longitude"]).to be nil
      expect(Setting["map.zoom"]).to be nil
    end

    it "does nothing if there is no location data in settings" do
      run_rake_task

      expect(Map.default.map_location.latitude).to eq default_latitude
      expect(Map.default.map_location.longitude).to eq default_longitude
      expect(Map.default.map_location.zoom).to eq default_zoom
    end
  end
end
