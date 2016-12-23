class Admin::Poll::PollsController < Admin::BaseController
  load_and_authorize_resource
  before_action :load_search, only: [:search_booths]

  def index
  end

  def show
    @poll = Poll.includes(:questions, :booths, :officers).find(params[:id])
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

  def search_booths
    @booths = ::Poll::Booth.search(@search)
    respond_to do |format|
      format.js
    end
  end

  private

    def poll_params
      params.require(:poll).permit(:name, :starts_at, :ends_at)
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end

end