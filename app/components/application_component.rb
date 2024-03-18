class ApplicationComponent < ViewComponent::Base
  include SettingsHelper
  use_helpers :back_link_to, :t
  delegate :default_form_builder, to: :controller
end
