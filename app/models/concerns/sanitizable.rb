module Sanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_description
    before_validation :sanitize_tag_list

    unless included_modules.include? Globalizable
      def description
        super.try :html_safe
      end
    end
  end

  protected

    def sanitize_description
      if translatable_description?
        sanitize_description_translations
      else
        self.description = WYSIWYGSanitizer.new.sanitize(description)
      end
    end

    def sanitize_tag_list
      self.tag_list = TagSanitizer.new.sanitize_tag_list(tag_list) if self.class.taggable?
    end

    def translatable_description?
      self.class.included_modules.include?(Globalizable) && self.class.translated_attribute_names.include?(:description)
    end

    def sanitize_description_translations
      # Sanitize description when using attribute accessor in place of nested translations.
      # This is because Globalize gem create translations on after save callback
      # https://github.com/globalize/globalize/blob/e37c471775d196cd4318e61954572c300c015467/lib/globalize/active_record/act_macro.rb#L105
      if translations.empty?
        Globalize.with_locale(I18n.locale) do
          self.description = WYSIWYGSanitizer.new.sanitize(description)
        end
      end

      translations.reject(&:_destroy).each do |translation|
        Globalize.with_locale(translation.locale) do
          self.description = WYSIWYGSanitizer.new.sanitize(description)
        end
      end
    end
end
