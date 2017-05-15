class ProblemsController < ApplicationController
  skip_authorization_check

  def show
    @problem = Problem.find(params[:id])
  end

end
