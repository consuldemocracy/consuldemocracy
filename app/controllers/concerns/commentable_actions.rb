module CommentableActions
  extend ActiveSupport::Concern
  include Polymorphic
  include Search

  def index
    @resources = resource_model.all

    @resources = if @current_order == "recommendations" && current_user.present?
                   @resources.recommendations(current_user)
                 else
                   @resources.for_render
                 end
    @resources = @resources.search(@search_terms) if @search_terms.present?
    @resources = @resources.filter_by(@advanced_search_terms)

    @resources = @resources.page(params[:page]).send("sort_by_#{@current_order}")

    index_customization

    set_resources_instance
    @remote_translation_resources = [*@resources, *featured_proposals]
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

  def edit
  end

  private

    def set_geozone
      geozone_id = params.dig(resource_name.to_sym, :geozone_id)
      @resource.geozone = Geozone.find(geozone_id) if geozone_id.present?
    end

    def load_categories
      @categories = Tag.category.order(:name)
    end

    def index_customization
      nil
    end

    def featured_proposals
      @featured_proposals ||= []
    end
end
