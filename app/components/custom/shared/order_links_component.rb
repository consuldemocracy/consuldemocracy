class Shared::OrderLinksComponent < ApplicationComponent; end
require_dependency Rails.root.join("app", "components", "shared", "order_links_component").to_s
class Shared::OrderLinksComponent
  # Your custom logic here
  private

    def html_class(order)
      if order == current_order
        "nav-link active"
      else
        "nav-link"
    end
end
end
