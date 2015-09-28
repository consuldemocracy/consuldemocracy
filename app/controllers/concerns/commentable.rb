module Commentable
  extend ActiveSupport::Concern

  def index
    @commentables = @search_terms.present? ? commentable_model.search(@search_terms) : commentable_model.all
    @commentables = @commentables.tagged_with(@tag_filter) if @tag_filter
    @commentables = @commentables.page(params[:page]).for_render.send("sort_by_#{@current_order}")
    @tag_cloud = tag_cloud

    set_commentable_votes(@commentables)
    set_commentables_instance
  end

  def show
    set_commentable_votes(commentable)
    @root_comments = commentable.comments.roots.recent.page(params[:page]).per(10).for_render
    @comments = @root_comments.inject([]){|all, root| all + Comment.descendants_of(root).for_render}
    @all_visible_comments = @root_comments + @comments

    set_comment_flags(@all_visible_comments)
    set_commentable_instance
  end

  def new
    @commentable = commentable_model.new
    set_commentable_instance
    load_featured_tags
  end

  def create
    @commentable = commentable_model.new(strong_params)
    @commentable.author = current_user

    if @commentable.save_with_captcha
      track_event
      redirect_to @commentable, notice: t('flash.actions.create.notice', resource_name: "#{controller_name.singularize.capitalize}")
    else
      load_featured_tags
      set_commentable_instance
      render :new
    end
  end

  def edit
    load_featured_tags
  end

  def update
    commentable.assign_attributes(strong_params)
    if commentable.save_with_captcha
      redirect_to commentable, notice: t('flash.actions.update.notice', resource_name: "#{controller_name.singularize.capitalize}")
    else
      load_featured_tags
      set_commentable_instance
      render :edit
    end
  end

  private
    def commentable
      @commentable ||= instance_variable_get("@#{controller_name.singularize}")
    end

    def commentable_model
      @commentable_model ||= controller_name.singularize.capitalize.constantize
    end

    def set_commentable_instance
      instance_variable_set("@#{controller_name.singularize}", @commentable)
    end

    def set_commentables_instance
      instance_variable_set("@#{controller_name}", @commentables)
    end

    def set_commentable_votes(instance)
      send("set_#{controller_name.singularize}_votes", instance)
    end

    def strong_params
      send("#{controller_name.singularize}_params")
    end

    def track_event
      ahoy.track "#{controller_name.singularize}_created".to_sym, "#{controller_name.singularize}_id": commentable.id
    end

    def tag_cloud
      commentable_model.tag_counts.order("#{controller_name}_count": :desc, name: :asc).limit(20)
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
end