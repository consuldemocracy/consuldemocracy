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
    # Check if multitenancy is enabled
      if Rails.application.config.multitenancy
      # Return the current schema as class unless it's 'public'
        current_schema = Tenant.current_schema
        return "class=\"tenant-#{current_schema}\"" unless current_schema == 'public'
      end

    # If multitenancy is not enabled or schema is 'public', use the site name
      if Rails.application.secrets.site_name.present?
       "class=\"site-#{Rails.application.secrets.site_name}\""
      end
    end

end
