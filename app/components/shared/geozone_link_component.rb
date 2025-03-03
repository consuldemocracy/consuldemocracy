class Shared::GeozoneLinkComponent < ApplicationComponent
  attr_reader :geozonable, :link
  use_helpers :geozone_name

  def initialize(geozonable, link)
    @geozonable = geozonable
    @link = link
  end

  def render?
    Geozone.any?
  end
end
