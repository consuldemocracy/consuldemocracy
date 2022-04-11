class Admin::Dashboard::ActionsController < Admin::Dashboard::BaseController
  include DocumentAttributes
  helper_method :dashboard_action, :resource

  def index
    @dashboard_actions = proposed_actions + resources
  end

  def new
    @dashboard_action = ::Dashboard::Action.new(
      active: true,
      day_offset: 0,
      required_supports: 0,
      request_to_administrators: false,
      action_type: "proposed_action"
    )
  end

  def create
    @dashboard_action = ::Dashboard::Action.new(dashboard_action_params)
    if @dashboard_action.save
      redirect_to admin_dashboard_actions_path, notice: t("admin.dashboard.actions.create.notice")
    else
      render :new
    end
  end

  def edit
    dashboard_action
  end

  def update
    if dashboard_action.update(dashboard_action_params)
      redirect_to admin_dashboard_actions_path
    else
      render :edit
    end
  end

  def destroy
    if dashboard_action.destroy
      flash[:notice] = t("admin.dashboard.actions.delete.success")
    else
      flash[:error] = dashboard_action.errors.full_messages.join(",")
    end

    redirect_to admin_dashboard_actions_path
  end

  private

    def resource
      @dashboard_action
    end

    def dashboard_action_params
      params.require(:dashboard_action).permit(allowed_params)
    end

    def allowed_params
      [
        :title, :description, :short_description, :request_to_administrators, :day_offset,
        :required_supports, :order, :active, :action_type, :published_proposal,
        documents_attributes: document_attributes,
        links_attributes: [:id, :label, :url, :_destroy]
      ]
    end

    def dashboard_action
      @dashboard_action ||= ::Dashboard::Action.find(params[:id])
    end

    def proposed_actions
      ::Dashboard::Action.proposed_actions.order(order: :asc)
    end

    def resources
      ::Dashboard::Action.resources.order(required_supports: :asc, day_offset: :asc)
    end
end
