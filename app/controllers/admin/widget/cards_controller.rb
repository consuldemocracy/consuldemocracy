class Admin::Widget::CardsController < Admin::BaseController
  include Admin::Widget::CardsActions
  load_and_authorize_resource :card, class: "Widget::Card"
  helper_method :index_path

  private

    def index_path
      admin_homepage_path
    end
end
