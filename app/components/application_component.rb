class ApplicationComponent < ViewComponent::Base
  include SettingsHelper
  use_helpers :back_link_to, :t, :include_html_editor
  delegate :default_form_builder, to: :controller
end
