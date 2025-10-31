class Admin::Poll::PollsController < Admin::Poll::BaseController
  include Translatable
  include ImageAttributes
  include ReportAttributes

  load_and_authorize_resource

  before_action :load_geozones, only: [:new, :create, :edit, :update]

  def index
    @polls = @polls.not_budget.created_by_admin.order(starts_at: :desc)
  end

  def show
  end

  def new
  end

  def create
    @poll.author = current_user

    if @poll.save
      notice = t("flash.actions.create.poll")
      if @poll.budget.present?
        redirect_to admin_poll_booth_assignments_path(@poll), notice: notice
      else
        redirect_to [:admin, @poll], notice: notice
      end
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

  def booth_assignments
    @polls = Poll.current.created_by_admin
  end

  def destroy
    if ::Poll::Voter.where(poll: @poll).any?
      redirect_to admin_poll_path(@poll), alert: t("admin.polls.destroy.unable_notice")
    else
      @poll.destroy!

      redirect_to admin_polls_path, notice: t("admin.polls.destroy.success_notice")
    end
  end

  private

    def load_geozones
      @geozones = Geozone.order(:name)
    end

    def poll_params
      params.require(:poll).permit(allowed_params)
    end

    def allowed_params
      attributes = [:name, :starts_at, :ends_at, :geozone_restricted, :budget_id, :related_sdg_list,
                    geozone_ids: [], image_attributes: image_attributes]

      [*attributes, *report_attributes, translation_params(Poll)]
    end
end
