class Admin::Projects::CardsController < Admin::BaseController
  include Admin::Widget::CardsActions
  load_and_authorize_resource :project, class: "Project"
  load_and_authorize_resource :card, through: :project, class: "Widget::Card"
  helper_method :index_path

  def index
  end

  private

    def index_path
      admin_project_widget_cards_path(@project)
    end
end
