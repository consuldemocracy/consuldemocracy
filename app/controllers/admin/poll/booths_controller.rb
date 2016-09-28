class Admin::Poll::BoothsController < Admin::BaseController
  load_and_authorize_resource :poll
  load_and_authorize_resource class: 'Poll::Booth', through: :poll

  before_action :load_polls, only: :index

  def index
  end

  def show
  end

  def new
  end

  def create
    if @booth.save
      redirect_to admin_poll_booth_path(@poll, @booth), notice: t("flash.actions.create.poll_booth")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @booth.update(booth_params)
      redirect_to admin_poll_booth_path(@poll, @booth), notice: t("flash.actions.update.poll_booth")
    else
      render :edit
    end
  end

  private

    def booth_params
      params.require(:poll_booth).permit(:name, :location)
    end

    def load_polls
      @polls = Poll.all
    end

end