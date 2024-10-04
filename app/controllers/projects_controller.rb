class ProjectsController < ApplicationController
  include FeatureFlags
  include Translatable

  feature_flag :projects

  before_action :load_project, only: :show

  skip_authorization_check
  helper_method :resource_model, :resource_name
  respond_to :html, :js
  load_and_authorize_resource

  has_filters %w[active archived]

  def show

    if not @project.published?
      raise ActiveRecord::RecordNotFound
    end
    @cards = @project.cards.sort_by_order
    
    if params[:phase]
      @active_phase=@project.phases.enabled.find(params[:phase])
    end
  end

  def index
    @projects = Kaminari.paginate_array(
      @projects.published.sort_by_created.send(@current_filter)
    ).page(params[:page]).per(9)
  end

  private

    def resource_model
      Project
    end

    def load_project
      @project = Project.find_by_slug_or_id! params[:id]
    end
end