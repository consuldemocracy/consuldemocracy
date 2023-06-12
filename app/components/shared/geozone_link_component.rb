class Shared::GeozoneLinkComponent < ApplicationComponent
  attr_reader :geozonable
  delegate :geozone_name, to: :helpers

  def initialize(geozonable)
    @geozonable = geozonable
  end
end
