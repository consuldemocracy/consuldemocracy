class Admin::Widget::CardsController < Admin::BaseController
  include Admin::Widget::CardsActions
  load_and_authorize_resource :card, class: "Widget::Card"

  private

    def index_path
      admin_homepage_path
    end
end
