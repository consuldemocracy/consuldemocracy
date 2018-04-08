module CommentableActions
  extend ActiveSupport::Concern
  include Polymorphic
  include Search

  def index
    @resources = resource_model.all

    @resources = @current_order == "recommendations" && current_user.present? ? @resources.recommendations(current_user) : @resources.for_render
    @resources = @resources.search(@search_terms) if @search_terms.present?
    @resources = @advanced_search_terms.present? ? @resources.filter(@advanced_search_terms) : @resources
    @resources = @resources.tagged_with(@tag_filter) if @tag_filter

    @resources = @resources.page(params[:page]).send("sort_by_#{@current_order}")

    index_customization if index_customization.present?

    @tag_cloud = tag_cloud
    @banners = Banner.with_active

    set_resource_votes(@resources)

    set_resources_instance
  end

  def show
    set_resource_votes(resource)
    @commentable = resource
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
    set_resource_instance
  end

  def new
    @resource = resource_model.new
    set_geozone
    set_resource_instance
  end

  def suggest
    @limit = 5
    @resources = @search_terms.present? ? resource_relation.search(@search_terms) : nil
  end

  def create
    @resource = resource_model.new(strong_params)
    @resource.author = current_user

    if @resource.save
      track_event
      redirect_path = url_for(controller: controller_name, action: :show, id: @resource.id)
      redirect_to redirect_path, notice: t("flash.actions.create.#{resource_name.underscore}")
    else
      load_categories
      load_geozones
      set_resource_instance
      render :new
    end
  end

  def edit
  end

  def update
    if resource.update(strong_params)
      redirect_to resource, notice: t("flash.actions.update.#{resource_name.underscore}")
    else
      load_categories
      load_geozones
      set_resource_instance
      render :edit
    end
  end

  def map
    @resource = resource_model.new
    @tag_cloud = tag_cloud
  end

  private

    def track_event
      ahoy.track "#{resource_name}_created".to_sym, "#{resource_name}_id": resource.id
    end

    def tag_cloud
      TagCloud.new(resource_model, params[:search])
    end

    def load_geozones
      @geozones = Geozone.all.order(name: :asc)
    end

    def set_geozone
      geozone_id = params[resource_name.to_sym].try(:[], :geozone_id)
      @resource.geozone = Geozone.find(geozone_id) if geozone_id.present?
    end

    def load_categories
      @categories = ActsAsTaggableOn::Tag.category.order(:name)
    end

    def parse_tag_filter
      if params[:tag].present?
        @tag_filter = params[:tag] if ActsAsTaggableOn::Tag.named(params[:tag]).exists?
      end
    end

    def set_resource_votes(instance)
      send("set_#{resource_name}_votes", instance)
    end

    def index_customization
      nil
    end

end
