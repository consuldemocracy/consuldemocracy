class Dashboard::PollsController < Dashboard::BaseController
  include DocumentAttributes

  before_action :load_poll, only: [:edit, :update, :destroy]
  before_action :authorize_manage_polls

  def index
    @polls = Poll.for(proposal)
  end

  def new
    @poll = Poll.for(proposal).new
  end

  def create
    @poll = Poll.for(proposal).new(poll_params.merge(author: current_user))
    if @poll.save
      redirect_to proposal_dashboard_polls_path(proposal), notice: t("flash.actions.create.poll")
    else
      render :new
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @poll.update(poll_params)
        format.html do
          redirect_to proposal_dashboard_polls_path(proposal),
                      notice: t("flash.actions.update.poll")
        end

        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @poll.errors.full_messages, status: :unprocessable_content }
      end
    end
  end

  def destroy
    if ::Poll::Voter.where(poll: @poll).any?
      redirect_to proposal_dashboard_polls_path(proposal), alert: t("dashboard.polls.poll.unable_notice")
    else
      @poll.destroy!

      redirect_to proposal_dashboard_polls_path(proposal), notice: t("dashboard.polls.poll.success_notice")
    end
  end

  private

    def load_poll
      @poll = Poll.for(proposal).includes(:questions).find(params[:id])
    end

    def poll_params
      params.require(:poll).permit(allowed_params)
    end

    def allowed_params
      [:name, :starts_at, :ends_at, :description, :results_enabled,
       questions_attributes: question_attributes]
    end

    def question_attributes
      [:id, :title, :author_id, :proposal_id, :_destroy,
       question_options_attributes: question_options_attributes]
    end

    def question_options_attributes
      [:id, :_destroy, :title, :description, :given_order, :question_id,
       documents_attributes: document_attributes]
    end

    def authorize_manage_polls
      authorize! :manage_polls, proposal
    end
end
