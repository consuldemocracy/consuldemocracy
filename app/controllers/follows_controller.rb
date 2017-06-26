class FollowsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def create
    @followable = find_followable
    @follow = Follow.create(user: current_user, followable: @followable)
    render :refresh_follow_button
  end

  def destroy
    @follow = Follow.find(params[:id])
    @followable = @follow.followable
    @follow.destroy
    render :refresh_follow_button
  end

  private

  def find_followable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end
end
