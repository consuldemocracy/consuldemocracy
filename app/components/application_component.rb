class ApplicationComponent < ViewComponent::Base
  include SettingsHelper
  delegate :back_link_to, to: :helpers
end
