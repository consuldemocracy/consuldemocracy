class PagesController < ApplicationController
  skip_authorization_check

  def show
    if @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])
      render action: :custom_page
    else
      render action: params[:id]
    end
  rescue ActionView::MissingTemplate
    head 404
  end
end
