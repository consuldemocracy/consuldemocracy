module Globalizable
  extend ActiveSupport::Concern

  included do
    globalize_accessors
    accepts_nested_attributes_for :translations, allow_destroy: true

    def locales_not_marked_for_destruction
      translations.reject(&:_destroy).map(&:locale)
    end

    def assign_model_to_translations
      translations.each { |translation| translation.globalized_model = self }
    end

    def description
      self.read_attribute(:description).try :html_safe
    end

    if self.paranoid? && translation_class.attribute_names.include?("hidden_at")
      translation_class.send :acts_as_paranoid, column: :hidden_at
    end

    private

      def searchable_globalized_values
        values = {}
        translations.each do |translation|
          Globalize.with_locale(translation.locale) do
            values.merge! searchable_translations_definitions
          end
        end
        values
      end
  end

  class_methods do
    def validates_translation(method, options = {})
      validates(method, options.merge(if: lambda { |resource| resource.translations.blank? }))
      translation_class.instance_eval { validates method, options }
    end

    def translation_class_delegate(method)
      translation_class.instance_eval { delegate method, to: :globalized_model }
    end
  end
end
