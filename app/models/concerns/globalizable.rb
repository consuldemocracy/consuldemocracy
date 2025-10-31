module Globalizable
  MIN_TRANSLATIONS = 1
  extend ActiveSupport::Concern

  included do
    globalize_accessors
    accepts_nested_attributes_for :translations, allow_destroy: true

    validate :check_translations_number, on: :update, if: :translations_required?
    after_validation :copy_error_to_current_translation, on: :update

    def locales_not_marked_for_destruction
      translations.reject(&:marked_for_destruction?).map(&:locale)
    end

    def locales_persisted_and_marked_for_destruction
      translations.select { |t| t.persisted? && t.marked_for_destruction? }.map(&:locale)
    end

    def translations_required?
      translated_attribute_names.any? { |attr| required_attribute?(attr) }
    end

    if paranoid? && translation_class.attribute_names.include?("hidden_at")
      translation_class.send :acts_as_paranoid, column: :hidden_at
    end

    private

      def required_attribute?(attribute)
        self.class.validators_on(attribute).any? do |validator|
          validator.kind == :presence && !conditional_validator?(validator)
        end
      end

      def conditional_validator?(validator)
        return false unless validator.options[:unless]

        if validator.options[:unless].to_proc.arity.zero?
          instance_exec(&validator.options[:unless])
        else
          validator.options[:unless].to_proc.call(self)
        end
      end

      def check_translations_number
        errors.add(:base, :translations_too_short) unless traslations_count_valid?
      end

      def traslations_count_valid?
        translations.reject(&:marked_for_destruction?).count >= MIN_TRANSLATIONS
      end

      def copy_error_to_current_translation
        return unless errors.added?(:base, :translations_too_short)

        if locales_persisted_and_marked_for_destruction.include?(I18n.locale)
          locale = I18n.locale
        else
          locale = locales_persisted_and_marked_for_destruction.first
        end

        translation = translation_for(locale)
        translation.errors.add(:base, :translations_too_short)
      end

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
      if options.include?(:length)
        translation_class.instance_eval do
          validates method,
                    length: options[:length],
                    if: lambda { |translation| translation.locale == Setting.default_locale }
        end
        if options.many?
          translation_class.instance_eval do
            validates method, options.reject { |key| key == :length }
          end
        end
      else
        translation_class.instance_eval { validates method, options }
      end
    end

    def translation_class_delegate(method)
      translation_class.instance_eval { delegate method, to: :globalized_model }
    end

    def with_fallback_translation
      translations_foreign_key = reflect_on_association(:translations).foreign_key
      fallbacks = Globalize.fallbacks(Globalize.locale)

      translations_ids = translation_class
                         .select("DISTINCT ON (#{translations_foreign_key}) id")
                         .where(locale: fallbacks)
                         .order(translations_foreign_key)
                         .in_order_of(:locale, fallbacks)

      with_translations(fallbacks).where("#{translations_table_name}.id": translations_ids)
    end
  end
end
