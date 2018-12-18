class Admin::SiteCustomization::CardsController < Admin::SiteCustomization::BaseController
    skip_authorization_check
  
    def index
      @cards = ::Widget::Card.page(params[:page_id])
    end

  end
  


