module CommentableActions
  extend ActiveSupport::Concern
  include Polymorphic

  def index
    @resources = @search_terms.present? ? resource_model.search(@search_terms) : resource_model.all

    #advanced search filters
    if @params_author
      author = User.where(username: @params_author)
      @resources = author.count > 0 ? @resources.where(author_id: author.first.id) : resource_model.none
    end
    if @params_date
      case @params_date
      when '1'
        min_date_time = DateTime.now -24.hour
      when '2'
        min_date_time = DateTime.now - 7.day
      when '3'
        min_date_time = DateTime.now - 30.day
      when '4'
        min_date_time = DateTime.now - 365.day
      when '5'
        @resources = @resources.where('created_at <= ?', @params_date_max) if @params_date_max
        min_date_time = @params_date_min
      end
      @resources = @resources.where('created_at >= ?', min_date_time) if min_date_time
    end
    if @params_author_type
      authors = User.where(official_level: @params_author_type.to_i)
      @resources = @resources.where('author_id IN (?)', authors.map(&:id))
    end

    @resources = @resources.tagged_with(@tag_filter) if @tag_filter
    @resources = @resources.page(params[:page]).for_render.send("sort_by_#{@current_order}")
    index_customization if index_customization.present?
    
    @tag_cloud = tag_cloud
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
    set_resource_instance
    load_featured_tags
  end

  def create
    @resource = resource_model.new(strong_params)
    @resource.author = current_user

    if @resource.save_with_captcha
      track_event
      redirect_path = url_for(controller: controller_name, action: :show, id: @resource.id)
      redirect_to redirect_path, notice: t('flash.actions.create.notice', resource_name: "#{resource_name.capitalize}")
    else
      load_featured_tags
      set_resource_instance
      render :new
    end
  end

  def edit
    load_featured_tags
  end

  def update
    resource.assign_attributes(strong_params)
    if resource.save_with_captcha
      redirect_to resource, notice: t('flash.actions.update.notice', resource_name: "#{resource_name.capitalize}")
    else
      load_featured_tags
      set_resource_instance
      render :edit
    end
  end

  private

    def track_event
      ahoy.track "#{resource_name}_created".to_sym, "#{resource_name}_id": resource.id
    end

    def tag_cloud
      resource_model.tag_counts.order("#{resource_name.pluralize}_count": :desc, name: :asc).limit(20)
    end

    def load_featured_tags
      @featured_tags = ActsAsTaggableOn::Tag.where(featured: true)
    end

    def parse_tag_filter
      if params[:tag].present?
        @tag_filter = params[:tag] if ActsAsTaggableOn::Tag.named(params[:tag]).exists?
      end
    end

    def parse_search_terms
      @search_terms = params[:search] if params[:search].present?
    end

    def parse_advanced_search_terms
      search = params[:advanced_search]
      if search
        @params_author = search[:author] if search[:author].present?
        @params_author_type = search[:author_type] if search[:author_type].present?
        @params_date = search[:date] if search[:date].present?
        @params_date_min = search[:date_min] if (@params_date == '5') && search[:date_min].present?
        @params_date_max = search[:date_max] if (@params_date == '5') && search[:date_max].present?
        @advanced_search_present = true if params[:commit] || @params_author || @params_author_type || @params_date
      end
    end

    def set_search_order
      if params[:search].present? && params[:order].blank?
        params[:order] = 'relevance'
      end
    end

    def set_resource_votes(instance)
      send("set_#{resource_name}_votes", instance)
    end

    def index_customization
      nil
    end
end
