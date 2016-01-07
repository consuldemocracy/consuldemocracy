class Geozone < ActiveRecord::Base
  validates :name, presence: true

  default_scope { order(name: :asc) }
end
