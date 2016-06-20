class AnswersController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  def index
  end

  def new
  end

  def create
    @answer.author = current_user
    @answer.context = "Derechos Humanos"
    if @answer.save
      redirect_to answers_path
    else
      render :new
    end
  end

  private

    def answer_params
      params.require(:answer).permit(:text)
    end

end
