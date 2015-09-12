class ProposalsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  load_and_authorize_resource
  respond_to :html, :js

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
      params.require(:proposal).permit(:title, :question, :description, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def load_featured_tags
      @featured_tags = ActsAsTaggableOn::Tag.where(featured: true)
    end
end