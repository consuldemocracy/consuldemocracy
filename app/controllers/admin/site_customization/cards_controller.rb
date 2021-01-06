class Admin::SiteCustomization::CardsController < Admin::SiteCustomization::BaseController
  skip_authorization_check
  load_and_authorize_resource :page, class: "::SiteCustomization::Page"
  load_and_authorize_resource :card, through: :page, class: "Widget::Card"

  def index
  end
end
