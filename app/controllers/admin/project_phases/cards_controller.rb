class Admin::ProjectPhases::CardsController < Admin::BaseController
  include Admin::Widget::CardsActions
  load_and_authorize_resource :project_phase, class: "Project::Phase"
  load_and_authorize_resource :card, through: :project_phase, class: "Widget::Card"
  helper_method :index_path

  def index
  end

  private

    def index_path
      admin_project_phase_widget_cards_path(@project_phase)
    end
end
