class Admin::Poll::QuestionsController < Admin::Poll::BaseController
  include CommentableActions

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: 'Poll::Question'

  def index
    @polls = Poll.all
    @search = search_params[:search]

    @questions = @questions.search(search_params).page(params[:page]).order("created_at DESC")

    @proposals = Proposal.successful.sort_by_confidence_score
  end

  def new
    @polls = Poll.all
    proposal = Proposal.find(params[:proposal_id]) if params[:proposal_id].present?
    @question.copy_attributes_from_proposal(proposal)
  end

  def create
    @question.author = @question.proposal.try(:author) || current_user

    if @question.save
      redirect_to admin_question_path(@question)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to admin_question_path(@question), notice: t("flash.actions.save_changes.notice")
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

    def question_params
      params.require(:poll_question).permit(:poll_id, :title, :question, :proposal_id, :video_url)
    end

    def search_params
      params.permit(:poll_id, :search)
    end

end
