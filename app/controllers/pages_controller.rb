class PagesController < ApplicationController
  skip_authorization_check

  def show
    render action: params[:id]
  end
end
