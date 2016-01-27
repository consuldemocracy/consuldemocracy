class OpenAnswersController < ApplicationController

  before_action :authenticate_user!
  skip_authorization_check

  def show
    @open_answers = OpenAnswer.where(question_code: params[:id]).page(params[:page]).sort_by_confidence_score
    if params[:id] == "16"
      @question = "¿Qué nuevos usos o enfoques de la Plaza te expulsarían de la zona?"
    elsif params[:id] == "17"
      @question = "¿Qué servicios, actividades o usos crees que faltan o piensas que sobran?"
    else
      head 404
    end
  end

  def vote
    @open_answer = OpenAnswer.find(params[:id])
    @open_answer.register_vote(current_user, params[:value])
  end

end