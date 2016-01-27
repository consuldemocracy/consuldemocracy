class SurveyAnswersController < ApplicationController

  before_action :authenticate_user!

  load_and_authorize_resource

  def new
  end

  def create
    SurveyAnswer.create(user: current_user, answers: questions_params)
  end

  private

    def questions_params
      params.require(:questions).permit(question_numbers)
    end

    def question_numbers
      %W(1a 1b 2 2g 3 3g 4 4l 5a 5b 5c 5d 5e 6 7 7d 8a 8b 9 9e 10 10h 11 11e 12a 12b 12c 13 14 14j 15a 15bCaminando 15bEnBicicleta 15bEnCoche 15bEnTransportePublico 15bOtros 15bOtrosEspecificar 16 17 18)
    end

end
