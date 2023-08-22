class Admin::Geozones::FormComponent < ApplicationComponent
  attr_reader :geozone

  def initialize(geozone)
    @geozone = geozone
  end
end
