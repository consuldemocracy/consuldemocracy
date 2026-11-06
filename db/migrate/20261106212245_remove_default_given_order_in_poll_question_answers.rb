class RemoveDefaultGivenOrderInPollQuestionAnswers < ActiveRecord::Migration[8.0]
  def change
    change_column_default :poll_question_answers, :given_order, from: 1, to: nil
    change_column_null :poll_question_answers, :given_order, false
  end
end
