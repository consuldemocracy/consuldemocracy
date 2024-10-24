class Proposals::GeozonesComponent < ApplicationComponent
  use_helpers :image_path_for

  def render?
    Geozone.any?
  end
end
