class CommunitiesController < ApplicationController

  before_action :set_community, :load_topics, only: :show

  skip_authorization_check

  def show
  end

  private

  def set_community
    @community = Community.find(params[:id])
  end

  def load_topics
    @topics = @community.topics
  end
end
