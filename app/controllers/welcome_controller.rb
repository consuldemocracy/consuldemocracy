class WelcomeController < ApplicationController
  skip_authorization_check

  layout "devise", only: [:welcome, :verification]

  def index
    if current_user
    end
    @proposal_successfull_exists = Proposal.successful.exists?
  end

  def welcome
  end

  def verification
    redirect_to verification_path if signed_in?
  end

end
