class Admin::SiteCustomization::CardsController < Admin::SiteCustomization::BaseController
  include Admin::Widget::CardsActions
  load_and_authorize_resource :page, class: "::SiteCustomization::Page"
  load_and_authorize_resource :card, through: :page, class: "Widget::Card"
  helper_method :index_path

  def index
  end

  private

    def index_path
      admin_site_customization_page_widget_cards_path(@page)
    end
end
