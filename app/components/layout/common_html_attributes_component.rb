class Layout::CommonHtmlAttributesComponent < ApplicationComponent
  use_helpers :rtl?

  private

    def attributes
      sanitize([dir, lang, html_class].compact.join(" "))
    end

    def dir
      'dir="rtl"' if rtl?
    end

    def lang
      "lang=\"#{I18n.locale}\""
    end

    def html_class
      "class=\"tenant-#{Tenant.current_schema}\"" if Rails.application.config.multitenancy
    end
end
