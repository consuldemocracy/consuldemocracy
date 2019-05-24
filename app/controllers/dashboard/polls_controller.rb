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

  def create
    authorize! :manage_polls, proposal

    @poll = Poll.new(poll_params.merge(author: current_user, related: proposal))
    if @poll.save
      redirect_to proposal_dashboard_polls_path(proposal), notice: t("flash.actions.create.poll")
    else
      render :new
    end
  end

  def edit
    authorize! :manage_polls, proposal
  end

  def update
    authorize! :manage_polls, proposal

    respond_to do |format|
      if poll.update(poll_params)
        format.html { redirect_to proposal_dashboard_polls_path(proposal),
                                  notice: t("flash.actions.update.poll") }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: poll.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  private

    def poll
      @poll ||= Poll.includes(:questions).find(params[:id])
    end

    def poll_params
      params.require(:poll).permit(poll_attributes)
    end

    def poll_attributes
      [:name, :starts_at, :ends_at, :description, :results_enabled,
       questions_attributes: question_attributes]
    end

    def question_attributes
      [:id, :title, :author_id, :proposal_id, :_destroy,
       question_answers_attributes: question_answers_attributes]
    end

    def question_answers_attributes
      [:id, :_destroy, :title, :description, :given_order, :question_id,
       documents_attributes: documents_attributes]
    end

    def documents_attributes
      [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
    end
end
