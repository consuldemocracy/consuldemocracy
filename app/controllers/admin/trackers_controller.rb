class Admin::TrackersController < Admin::BaseController
  load_and_authorize_resource

  before_action :set_tracker, only: [:show, :edit, :update, :destroy]

  def show
    @tracker = Tracker.find(params[:id])
  end

  def index
    @trackers = @trackers.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
               .includes(:tracker)
               .page(params[:page])
               .for_render
  end

  def create
    @tracker = Tracker.new(tracker_params)
    @tracker.save

    redirect_to admin_trackers_path
  end

  def edit
    @tracker = Tracker.find(params[:id])
  end

  def update
    @tracker = Tracker.find(params[:id])
    if @tracker.update(tracker_params)
      notice = t("admin.trackers.form.updated")
      redirect_to [:admin, @tracker], notice: notice
    else
      render :edit
    end
  end

  def destroy
    @tracker.destroy
    redirect_to admin_trackers_path
  end

  private
    def set_tracker
      @tracker = Tracker.find(params[:id])
    end

    def tracker_params
      params[:tracker][:description] = nil if params[:tracker][:description].blank?
      params.require(:tracker).permit(:user_id, :description, :budget_investment_count)
    end
end
