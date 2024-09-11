class Admin::Settings::MapTabComponent < ApplicationComponent
  def tab
    "#tab-map-configuration"
  end

  def settings
    %w[
      map.latitude
      map.longitude
      map.zoom
    ]
  end
end
