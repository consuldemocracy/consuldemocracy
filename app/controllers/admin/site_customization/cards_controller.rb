class Admin::SiteCustomization::CardsController < Admin::SiteCustomization::BaseController
  skip_authorization_check

  def index
    @page = ::SiteCustomization::Page.find(params[:page_id])
    @cards = @page.cards
  end

end
