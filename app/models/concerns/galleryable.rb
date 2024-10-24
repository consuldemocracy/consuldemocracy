module Galleryable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :imageable, inverse_of: :imageable, dependent: :destroy
    accepts_nested_attributes_for :images, allow_destroy: true, update_only: true
  end
end
