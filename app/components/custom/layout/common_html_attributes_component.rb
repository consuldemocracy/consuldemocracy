class Layout::CommonHTMLAttributesComponent < ApplicationComponent; end
load Rails.root.join("app", "components", "layout", "common_html_attributes_component.rb")

class Layout::CommonHTMLAttributesComponent
  use_helpers :rtl?

  private
#    alias_method :consul_html_class, :html_class


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
        # else consul_html_class  
      end
    end
end