class WelcomeController < ApplicationController
  skip_authorization_check

  layout "devise", only: [:welcome, :verification]

  def index
    if current_user
      if Setting["feature.concurso_cartel_magdalena"]
        redirect_to page_path('concurso_cartel_magdalena')
      else
        redirect_to :budgets
      end
    end
  end

  def welcome
  end

  def verification
    redirect_to verification_path if signed_in?
  end

end
