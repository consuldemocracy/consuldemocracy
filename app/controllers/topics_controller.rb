class TopicsController < ApplicationController
  include CommentableActions

  before_action :set_community

  has_orders %w{most_voted newest oldest}, only: :show

  skip_authorization_check

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params.merge(author: current_user, community_id: params[:community_id]))

    if @topic.save
      redirect_to community_path(@community), notice: I18n.t('flash.actions.create.topic')
    else
      render :new
    end
  end

  def show
    @topic = Topic.find(params[:id])
    @commentable = @topic
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update(topic_params)
      redirect_to community_path(@community), notice: t('topic.update.notice')
    else
      render :edit
    end
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :community_id)
  end

  def set_community
    @community = Community.find(params[:community_id])
  end
end
