class ForumsController < ApplicationController

  before_action :authenticate_user!
  skip_authorization_check

  def index
    @forums = Forum.all.order(name: :asc)
  end

  def show
    @user = current_user
    @forum = Forum.find(params[:id])
  end

end