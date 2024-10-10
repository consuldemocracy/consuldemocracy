class Layout::CommonHtmlAttributesComponent < ApplicationComponent
  use_helpers :rtl?

  private

    def attributes
      tag.attributes(dir: dir, lang: lang, class: html_class)
    end

    def dir
      "rtl" if rtl?
    end

    def lang
      I18n.locale
    end

    def html_class
      "tenant-#{Tenant.current_schema}" if Rails.application.config.multitenancy
    end
end
