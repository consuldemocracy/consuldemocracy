class Layout::FooterComponent < ApplicationComponent
  def render?
    !Rails.application.multitenancy_management_mode?
  end
end
