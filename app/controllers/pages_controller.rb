class PagesController < ApplicationController
  include FeatureFlags

  skip_authorization_check

  feature_flag :help_page, if: lambda { params[:id] == "help/index" }

  def show
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])

    if @custom_page.present?
      @cards = @custom_page.cards.sort_by_order
      render action: :custom_page
    else
      render action: params[:id].split(".").first
    end
  rescue ActionView::MissingTemplate
    head :not_found, content_type: "text/html"
  end
end
