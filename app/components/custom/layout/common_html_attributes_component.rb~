require_dependency Rails.root.join("app", "components", "layout", "common_html_attributes_component").to_s

class Layout::CommonHTMLAttributesComponent
  private

    alias_method :consul_html_class, :html_class

    def html_class
      if Rails.application.secrets.site_name.present?
        "class=\"site-#{Rails.application.secrets.site_name}\""
      else
        consul_html_class
      end
    end
end
