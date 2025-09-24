class Layout::CommonHtmlAttributesComponent < ApplicationComponent
  delegate :rtl?, to: :helpers

  private

    def attributes
      tag.attributes(dir: dir, lang: lang, class: html_class, data: data)
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

    def data
      { warning_for_external_links: warning_for_external_links_text }
    end

    def warning_for_external_links_text
      t("shared.warning_for_external_links") if feature?("gdpr.warning_for_external_links")
    end
end
