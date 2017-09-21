class TopicsController < ApplicationController
  include CommentableActions

  before_action :load_community
  before_action :load_topic, only: [:show, :edit, :update, :destroy]

  has_orders %w{most_voted newest oldest}, only: :show

  skip_authorization_check only: :show
  load_and_authorize_resource except: :show

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
    @commentable = @topic
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

  def edit
  end

  def update
    if @topic.update(topic_params)
      redirect_to community_path(@community), notice: t('flash.actions.update.topic')
    else
      render :edit
    end
  end

  def destroy
    @topic.destroy
    redirect_to community_path(@community), notice: I18n.t('flash.actions.destroy.topic')
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :description)
  end

  def load_community
    @community = Community.find(params[:community_id])
  end

  def load_topic
    @topic = Topic.find(params[:id])
  end
end
