load Rails.root.join("app","components","layout","common_html_attributes_component.rb")

class Layout::CommonHtmlAttributesComponent
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
        if Rails.application.secrets.site_name.present?
        "class=\"site-#{Rails.application.secrets.site_name}\""
      else
        "class=\"tenant-#{Tenant.current_schema}\"" if Rails.application.config.multitenancy
      end

    end
end
