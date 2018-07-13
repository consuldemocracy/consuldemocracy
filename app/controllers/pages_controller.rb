class PagesController < ApplicationController
  skip_authorization_check

  def show
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])
    @banners = Banner.in_section('help_page').with_active

    if @custom_page.present?
      render action: :custom_page
    else
      render action: params[:id]
    end
  rescue ActionView::MissingTemplate
    head 404
  end
end
