class DashboardController < Dashboard::BaseController
  helper_method :dashboard_action, :active_resources, :course

  def index
    authorize! :dashboard, proposal
  end

  def publish
    authorize! :publish, proposal

    proposal.publish
    redirect_to proposal_dashboard_index_path(proposal), notice: t('proposals.notice.published')
  end

  def execute
    authorize! :dashboard, proposal

    Dashboard::ExecutedAction.create(proposal: proposal, action: dashboard_action, executed_at: Time.now)
    redirect_to progress_proposal_dashboard_index_path(proposal.to_param)
  end

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

      redirect_to progress_proposal_dashboard_index_path(proposal.to_param), { flash: { info: t('.success') } }
    else
      flash.now[:alert] = @dashboard_executed_action.errors.full_messages.join('<br>')
      render :new_request
    end
  end

  def progress 
    authorize! :dashboard, proposal
  end

  def community
    authorize! :dashboard, proposal
  end

  def supports
    authorize! :dashboard, proposal
    render json: ProposalSupportsQuery.for(params)
  end

  def successful_supports
    authorize! :dashboard, proposal
    render json: SuccessfulProposalSupportsQuery.for(params)
  end

  def achievements
    authorize! :dashboard, proposal
    render json: ProposalAchievementsQuery.for(params)
  end

  private

  def dashboard_action
    @dashboard_action ||= Dashboard::Action.find(params[:id])
  end

  def active_resources
    @active_resources ||= Dashboard::Action.active.resources.order(required_supports: :asc, day_offset: :asc)
  end

  def course
    @course ||= Dashboard::Action.course_for(proposal)
  end
end
