class ProjectsController < ApplicationController
  skip_authorization_check

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
  end



  private

    def project_params
      params.require(:project).permit(:name)
    end

end
