class ApplicationComponent < ViewComponent::Base
  include SettingsHelper

  delegate :back_link_to, :t, :can?, :cannot?, :current_user, to: :helpers
  delegate :default_form_builder, to: :controller
end
