class Dashboard::PollsController < Dashboard::BaseController 
  helper_method :poll

  def index
    authorize! :manage_polls, proposal

    @polls = Poll.for(proposal)
  end

  def new
    authorize! :manage_polls, proposal
    @poll = Poll.new
  end

  def show
    authorize! :manage_polls, proposal
  end

  def create
    authorize! :manage_polls, proposal

    @poll = Poll.new(poll_params.merge(author: current_user, related: proposal))
    if @poll.save
      redirect_to proposal_dashboard_poll_path(proposal, poll), notice: t("flash.actions.create.poll")
    else
      render :new
    end
  end

  def edit
    authorize! :manage_polls, proposal
  end

  def update
    authorize! :manage_polls, proposal

    if poll.update(poll_params)
      redirect_to proposal_dashboard_poll_path(proposal, poll), notice: t("flash.actions.update.poll")
    else
      render :edit
    end
  end

  def results
    authorize! :manage_polls, proposal
    @partial_results = poll.partial_results
  end

  private

  def poll
    @poll ||= Poll.includes(:questions).find(params[:id])
  end

  def poll_params
    params.require(:poll).permit(poll_attributes)
  end

  def poll_attributes
    [:name, :starts_at, :ends_at, :description,
     :results_enabled, :stats_enabled,
     questions_attributes: question_attributes]
  end

  def question_attributes
    [:id, :title, :author_id, :proposal_id, :_destroy, question_answers_attributes: question_answers_attributes]
  end

  def question_answers_attributes
    [:id, :_destroy, :title, :description, :question_id, documents_attributes: documents_attributes]
  end

  def documents_attributes
    [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
  end
end
