class SDGManagement::HeaderController < SDGManagement::BaseController
  include Admin::Widget::CardsActions
  helper_method :index_path

  before_action :load_cardable
  load_and_authorize_resource :header,
                              class: "Widget::Card",
                              through: :cardable,
                              singleton: true,
                              instance_name: :card

  private

    def load_cardable
      @cardable = WebSection.find_by!(name: "sdg")
    end

    def index_path
      sdg_management_homepage_path
    end

    def form_path
      sdg_management_homepage_header_path
    end

    def header_params
      card_params
    end
end
