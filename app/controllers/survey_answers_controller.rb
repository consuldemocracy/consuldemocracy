class SurveyAnswersController < ApplicationController

  before_action :authenticate_user!

  load_and_authorize_resource

  def new
  end

  def create
    SurveyAnswer.create!(user: current_user, answers: questions_params)
  end

  private

    def questions_params
      question_numbers = %W(1a 1b 2 2g 3 3l 4a 4b 4c 4d 4e 5 6 7 8a 8b 9 10 11 12a 12b 12c 13 13j 14 15a 15bCaminando 15bEnBicicleta 15bEnCoche 15bEnTransportePublico 15bOtrosEspecificar 15bOtros 16 17 18)
      params.require(:questions).permit(question_numbers)
    end

end
