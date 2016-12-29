class API::Geozone

  attr_accessor :geozone

  def initialize(id)
    @geozone = ::Geozone.find(id)
  end

  def self.public_columns
    ["id", "name"]
  end

  def public_attributes
    geozone.attributes.values_at(*API::Geozone.public_columns)
  end

  def public?
    true
  end

end