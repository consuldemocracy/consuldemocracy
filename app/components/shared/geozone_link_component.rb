class Shared::GeozoneLinkComponent < ApplicationComponent
  attr_reader :geozonable, :link
  delegate :geozone_name, to: :helpers

  def initialize(geozonable, link)
    @geozonable = geozonable
    @link = link
  end

  def render?
    Geozone.any?
  end
end
