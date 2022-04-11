require_dependency Rails.root.join("app", "controllers", "welcome_controller").to_s

class WelcomeController < ApplicationController
  skip_authorization_check

  before_action only: [:index]

  layout "devise", only: [:verification]
end
