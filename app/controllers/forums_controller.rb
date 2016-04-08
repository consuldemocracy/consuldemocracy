class ForumsController < ApplicationController

  skip_authorization_check

  def index
    @forums = Forum.all.order(name: :asc)
  end

  def show
    @forum = Forum.find(params[:id])
  end

end