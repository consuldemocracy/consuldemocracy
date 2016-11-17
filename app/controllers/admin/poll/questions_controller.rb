class Admin::Poll::QuestionsController < Admin::BaseController
  load_and_authorize_resource :question, class: 'Poll::Question'

  before_action :load_geozones, only: [:new, :create, :edit, :update]

  def index
    @questions = @questions.page(params[:page])
  end

  def new
    @question.valid_answers = I18n.t('questions.default_valid_answers')
    proposal = Proposal.find(params[:proposal_id]) if params[:proposal_id].present?
    @question.copy_attributes_from_proposal(proposal)
  end

  def create
    @question.author = @question.proposal.try(:author) || current_user

    if @question.save
      redirect_to question_path(@question)
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @question.update(question_params)
      redirect_to question_path(@question), notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def destroy
    if @question.destroy
      notice = "Question destroyed succesfully"
    else
      notice = t("flash.actions.destroy.error")
    end
    redirect_to admin_questions_path, notice: notice
  end

  private

    def load_geozones
      @geozones = Geozone.all.order(:name)
    end

    def question_params
      params.require(:poll_question).permit(:title, :question, :summary, :description, :proposal_id, :valid_answers, :geozone_ids => [])
    end

end