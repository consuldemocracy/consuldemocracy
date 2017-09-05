class CommunitiesController < ApplicationController

  before_action :set_order, :set_community, :load_topics, :load_participants, only: :show

  has_orders %w{newest most_commented oldest}, only: :show

  skip_authorization_check

  def show
    redirect_to root_path unless Setting['feature.community'].present?
  end

  private

  def set_order
    @order = params[:order].present? ? params[:order] : "newest"
  end

  def set_community
    @community = Community.find(params[:id])
  end

  def load_topics
    @topics = @community.topics.send("sort_by_#{@order}").page(params[:page])
  end

  def load_participants
    @participants = @community.participants
  end
end
