class Admin::Poll::PollsController < Admin::Poll::BaseController
  load_and_authorize_resource

  before_action :load_search, only: [:search_booths, :search_officers]
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

  def booth_assignments
    @polls = Poll.current_or_incoming
  end

  private

    def load_geozones
      @geozones = Geozone.all.order(:name)
    end

    def poll_params
      params.require(:poll).permit(:name, :starts_at, :ends_at, :geozone_restricted,
                                  :summary, :description, :results_enabled, :stats_enabled,
                                  geozone_ids: [],
                                  image_attributes: [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy])
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end

end
