class ProjectsController < ApplicationController
  skip_authorization_check

  def show
    @project = Project.find(params[:id])
  end

end
