module Mappable
  extend ActiveSupport::Concern

  included do
    has_one :map_location, dependent: :destroy
    accepts_nested_attributes_for :map_location, allow_destroy: true
  end

end
