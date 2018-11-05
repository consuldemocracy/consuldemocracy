module ModerateActions
  extend ActiveSupport::Concern
  include Polymorphic

  def index
    @resources = @resources.send(@current_filter)
                           .send("sort_by_#{@current_order}")
                           .page(params[:page])
                           .per(50)
    set_resources_instance
  end

  def hide
    hide_resource resource
  end

  def moderate
    set_resource_params
    @resources = @resources.where(id: params[:resource_ids])

    if params[:hide_resources].present?
      @resources.accessible_by(current_ability, :hide).each {|resource| hide_resource resource}

    elsif params[:ignore_flags].present?
      @resources.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)

    elsif params[:block_authors].present?
      author_ids = @resources.pluck(author_id).uniq
      User.where(id: author_ids).accessible_by(current_ability, :block).each {|user| block_user user}
    end

    redirect_to request.query_parameters.merge(action: :index)
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

    def set_resource_params
      params[:resource_ids] = params["#{resource_name}_ids"]
      params[:hide_resources] = params["hide_#{resource_name.pluralize}"]
    end

    def author_id
      :author_id
    end

end
