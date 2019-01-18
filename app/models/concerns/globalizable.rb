module Globalizable
  extend ActiveSupport::Concern

  included do
    globalize_accessors
    accepts_nested_attributes_for :translations, allow_destroy: true

    def locales_not_marked_for_destruction
      translations.reject(&:_destroy).map(&:locale)
    end
  end

  class_methods do
    def validates_translation(method, options = {})
      validates(method, options.merge(if: lambda { |resource| resource.translations.blank? }))
      translation_class.instance_eval { validates method, options }
    end
  end
end
