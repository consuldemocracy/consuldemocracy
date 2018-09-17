class Dashboard::ActionsController < Dashboard::BaseController 
  helper_method :dashboard_action

  def new_request
    authorize! :dashboard, proposal
    @dashboard_executed_action = Dashboard::ExecutedAction.new
  end

  def create_request
    authorize! :dashboard, proposal

    source_params = {
      proposal: proposal, 
      action: dashboard_action, 
      executed_at: Time.now
    }

    @dashboard_executed_action = Dashboard::ExecutedAction.new(source_params)
    if @dashboard_executed_action.save
      Dashboard::AdministratorTask.create(source: @dashboard_executed_action)

      redirect_to progress_proposal_dashboard_path(proposal.to_param), { flash: { info: t('dashboard.create_request.success') } }
    else
      flash.now[:alert] = @dashboard_executed_action.errors.full_messages.join('<br>')
      render :new_request
    end
  end

  def execute
    authorize! :dashboard, proposal

    Dashboard::ExecutedAction.create(proposal: proposal, action: dashboard_action, executed_at: Time.now)
    redirect_to progress_proposal_dashboard_path(proposal.to_param)
  end

  private

  def dashboard_action
    @dashboard_action ||= Dashboard::Action.find(params[:id])
  end
end

