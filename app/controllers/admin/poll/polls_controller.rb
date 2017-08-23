class Admin::Poll::PollsController < Admin::BaseController
  load_and_authorize_resource

  before_action :load_search, only: [:search_booths, :search_questions, :search_officers]
  before_action :load_geozones, only: [:new, :create, :edit, :update]

  def index
  end

  def show
    @poll = Poll.includes(:questions).
                          order('poll_questions.title').
                          find(params[:id])
  end

  def new
  end

  def create
    if @poll.save
      redirect_to [:admin, @poll], notice: t("flash.actions.create.poll")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @poll.update(poll_params)
      redirect_to [:admin, @poll], notice: t("flash.actions.update.poll")
    else
      render :edit
    end
  end

  def add_question
    question = ::Poll::Question.find(params[:question_id])

    if question.present?
      @poll.questions << question
      notice = t("admin.polls.flash.question_added")
    else
      notice = t("admin.polls.flash.error_on_question_added")
    end
    redirect_to admin_poll_path(@poll), notice: notice
  end

  def remove_question
    question = ::Poll::Question.find(params[:question_id])

    if @poll.questions.include? question
      @poll.questions.delete(question)
      notice = t("admin.polls.flash.question_removed")
    else
      notice = t("admin.polls.flash.error_on_question_removed")
    end
    redirect_to admin_poll_path(@poll), notice: notice
  end

  def search_questions
    @questions = ::Poll::Question.where("poll_id IS ? OR poll_id != ?", nil, @poll.id).search(search: @search).order(title: :asc)
    respond_to do |format|
      format.js
    end
  end

  private

    def load_geozones
      @geozones = Geozone.all.order(:name)
    end

    def poll_params
      params.require(:poll).permit(:name, :starts_at, :ends_at, :geozone_restricted, geozone_ids: [])
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end

end
