class CommunitiesController < ApplicationController

  before_action :set_order, :set_community, :load_topics, only: :show

  has_orders %w{newest most_commented oldest}, only: :show

  skip_authorization_check

  def show
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
end
