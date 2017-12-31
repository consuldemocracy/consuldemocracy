class CommunitiesController < ApplicationController
  TOPIC_ORDERS = %w{newest most_commented oldest}.freeze
  before_action :set_order, :set_community, :load_topics, :load_participants

  has_orders TOPIC_ORDERS

  skip_authorization_check

  def show
    redirect_to root_path if Setting['feature.community'].blank?
  end

  private

  def set_order
    @order = valid_order? ? params[:order] : "newest"
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

  def valid_order?
    params[:order].present? && TOPIC_ORDERS.include?(params[:order])
  end
end
