class SurveyAnswer < ActiveRecord::Base
  belongs_to :user

  def self.user_input(user, code, answers)
    SurveyAnswer.where(user_id: user.id).where(survey_code: code).destroy_all

    survey_answer = SurveyAnswer.create(user_id: user.id, survey_code: code, answers: answers)
    survey_answer.create_open_answers
  end

  def create_open_answers
    ['16', '17'].each do |n|
      text = answers[n] || ""

      OpenAnswer.create(survey_code: survey_code, text: text.strip, question_code: n.to_i, user_id: user_id) if text.strip.present?
    end
  end
end
