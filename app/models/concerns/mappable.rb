module Mappable
  extend ActiveSupport::Concern

  included do
    has_one :map_location, dependent: :destroy
    accepts_nested_attributes_for :map_location, allow_destroy: true, reject_if: :all_blank

    def feature_maps?
      Setting["feature.map"].present?
    end
  end
end
