class Admin::Poll::PollsController < Admin::BaseController
  load_and_authorize_resource

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

  private

    def poll_params
      params.require(:poll).permit(:name, :starts_at, :ends_at)
    end

end