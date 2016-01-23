class PagesController < ApplicationController
  skip_authorization_check

  def show
    render action: params[:id]
  rescue ActionView::MissingTemplate
    head 404
  end
end
