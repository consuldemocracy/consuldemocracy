class Layout::LocaleSwitcherComponent < ApplicationComponent
  delegate :name_for_locale, :current_path_with_query_params, to: :helpers
end
