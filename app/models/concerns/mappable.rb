module Mappable
  extend ActiveSupport::Concern

  included do
    attr_accessor :skip_map

    has_one :map_location, dependent: :destroy
    accepts_nested_attributes_for :map_location, allow_destroy: true, reject_if: :all_blank

    validate :map_must_be_valid, on: :create, if: :feature_maps?

    def map_must_be_valid
      return true if skip_map?

      unless map_location.try(:available?)
        skip_map_error = I18n.t('activerecord.errors.models.map_location.attributes.map.invalid')
        errors.add(:skip_map, skip_map_error)
      end
    end

    def feature_maps?
      Setting["feature.map"].present?
    end

    def skip_map?
      skip_map == "1"
    end

  end

end
