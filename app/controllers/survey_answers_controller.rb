class SurveyAnswersController < ApplicationController

  before_action :authenticate_user!, only: :create
  before_action :check_participation

  load_and_authorize_resource

  def new
  end

  def create
    SurveyAnswer.user_input(current_user, survey_code, questions_params)
    redirect_to encuesta_plaza_espana_respuestas_path
  end

  private

    def questions_params
      params.require(:questions).permit(question_numbers)
    end

    def question_numbers
      %W(1a 1b 2 2g 3 3g 4 4l 5a 5b 5c 5d 5e 6 7 7d 8a 8b 9 9e 10 10h 11 11e 12a 12b 12c 13 14 14j 15a 15bCaminando 15bEnBicicleta 15bEnCoche 15bEnTransportePublico 15bOtros 15bOtrosEspecificar 16 17 18)
    end

    def survey_code
      1
    end

    def check_participation
      if current_user && SurveyAnswer.exists?(user_id: current_user.id, survey_code: survey_code)
        redirect_to encuesta_plaza_espana_respuestas_path
      end
    end

end
