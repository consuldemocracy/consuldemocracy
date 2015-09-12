class ProposalsController < ApplicationController
  before_action :parse_order, only: :index
  before_action :parse_tag_filter, only: :index
  before_action :parse_search_terms, only: :index
  before_action :authenticate_user!, except: [:index, :show]

  load_and_authorize_resource
  respond_to :html, :js

  def index
    @proposals = @search_terms.present? ? Proposal.search(@search_terms) : Proposal.all
    @proposals = @proposals.tagged_with(@tag_filter) if @tag_filter
    @proposals = @proposals.page(params[:page]).for_render.send("sort_by_#{@order}")
    @tag_cloud = Proposal.tag_counts.order(taggings_count: :desc, name: :asc).limit(20)
    set_proposal_votes(@proposals)
  end

  def show
    set_proposal_votes(@proposal)
    @commentable = @proposal
    @root_comments = @proposal.comments.roots.recent.page(params[:page]).per(10).for_render
    @comments = @root_comments.inject([]){|all, root| all + Comment.descendants_of(root).for_render}

    @all_visible_comments = @root_comments + @comments
    set_comment_flags(@all_visible_comments)
  end

  def new
    @proposal = Proposal.new
    load_featured_tags
  end

  def create
    @proposal = Proposal.new(proposal_params)
    @proposal.author = current_user

    if @proposal.save_with_captcha
      ahoy.track :proposal_created, proposal_id: @proposal.id
      redirect_to @proposal, notice: t('flash.actions.create.notice', resource_name: 'proposal')
    else
      load_featured_tags
      render :new
    end
  end

  def edit
    load_featured_tags
  end

  def update
    @proposal.assign_attributes(proposal_params)
    if @proposal.save_with_captcha
      redirect_to @proposal, notice: t('flash.actions.update.notice', resource_name: 'Proposal')
    else
      load_featured_tags
      render :edit
    end
  end

  private

    def proposal_params
      params.require(:proposal).permit(:title, :question, :description, :external_url, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def load_featured_tags
      @featured_tags = ActsAsTaggableOn::Tag.where(featured: true)
    end

    def parse_order
      @valid_orders = ['confidence_score', 'hot_score', 'created_at', 'most_commented', 'random']
      @order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first
    end

    def parse_tag_filter
      if params[:tag].present?
        @tag_filter = params[:tag] if ActsAsTaggableOn::Tag.where(name: params[:tag]).exists?
      end
    end

    def parse_search_terms
      @search_terms = params[:search] if params[:search].present?
    end
end