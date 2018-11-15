class Admin::MilestonesController < Admin::BaseController
  include Translatable

  before_action :load_milestoneable, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :load_milestone, only: [:edit, :update, :destroy]
  before_action :load_statuses, only: [:index, :new, :create, :edit, :update]
  helper_method :milestoneable_path

  def index
  end

  def new
    @milestone = @milestoneable.milestones.new
  end

  def create
    @milestone = @milestoneable.milestones.new(milestone_params)
    if @milestone.save
      redirect_to milestoneable_path, notice: t('admin.milestones.create.notice')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @milestone.update(milestone_params)
      redirect_to milestoneable_path, notice: t('admin.milestones.update.notice')
    else
      render :edit
    end
  end

  def destroy
    @milestone.destroy
    redirect_to milestoneable_path, notice: t('admin.milestones.delete.notice')
  end

  private

  def milestone_params
    image_attributes = [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
    documents_attributes = [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
    attributes = [:publication_date, :status_id,
                  translation_params(Milestone),
                  image_attributes: image_attributes, documents_attributes: documents_attributes]

    params.require(:milestone).permit(*attributes)
  end

  def load_milestoneable
    @milestoneable = milestoneable
  end

  def milestoneable
    raise "Implement in subclass"
  end

  def load_milestone
    @milestone = @milestoneable.milestones.find(params[:id])
  end

  def load_statuses
    @statuses = Milestone::Status.all
  end

  def milestoneable_path
    polymorphic_path([:admin, *resource_hierarchy_for(@milestone.milestoneable)])
  end
end
