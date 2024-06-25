class Admin::Locales::ShowComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "admin", "locales", "show_component.rb")

class Admin::Locales::ShowComponent
  use_helpers :can?
end
