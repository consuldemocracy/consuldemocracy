require_dependency Rails.root.join("app", "controllers", "welcome_controller").to_s

class WelcomeController < ApplicationController
  skip_authorization_check

  before_action :load_budgets, only: [:index]

  layout "devise", only: [:verification]

  def load_budgets
    @budgets = Budget.where("id > -1");
  end

end
