module ModerateActions
  extend ActiveSupport::Concern
  include Polymorphic

  PER_PAGE = 50

  def index
    @resources = @resources.send(@current_filter)
                           .send("sort_by_#{@current_order}")
                           .page(params[:page])
                           .per(PER_PAGE)
    set_resources_instance
  end

  def hide
    hide_resource resource
    respond_to do |format|
      format.js do
        render "moderation/shared/hide", locals: { resource: resource }
      end
    end
  end

  def moderate
    @resources = @resources.where(id: params[:ids])

    if params[:hide_resources].present?
      @resources.accessible_by(current_ability, :hide).each { |resource| hide_resource resource }
    elsif params[:ignore_flags].present?
      @resources.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)
    elsif params[:block_authors].present?
      author_ids = @resources.pluck(author_id)
      User.where(id: author_ids).accessible_by(current_ability, :block).each { |user| block_user user }
    end

    redirect_with_query_params_to(action: :index)
  end

  private

    def load_resources
      @resources = resource_model.accessible_by(current_ability, :moderate)
    end

    def hide_resource(resource)
      resource.hide
      Activity.log(current_user, :hide, resource)
    end

    def block_user(user)
      user.block
      Activity.log(current_user, :block, user)
    end

    def author_id
      :author_id
    end
end
