class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: [:edit, :update, :destroy]

  # GET /admin/events
  # Shows a list (table) of manual events for easy management
  def index
    @events = Event.order(starts_at: :desc).page(params[:page])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to admin_events_path, notice: "Event created successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to admin_events_path, notice: "Event updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_events_path, notice: "Event deleted."
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :name,
      :description,
      :image,
      :starts_at,
      :ends_at,
      :location,
      :event_type,
      documents_attributes: [:id, :title, :user_id, :cached_attachment, :attachment, :_destroy]
    )
  end
end

