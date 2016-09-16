class PagesController < ApplicationController
  skip_authorization_check

  def show
    @proposal_successfull_exists = Proposal.successfull.exists?
    render action: params[:id]
  rescue ActionView::MissingTemplate
    head 404
  end

end
