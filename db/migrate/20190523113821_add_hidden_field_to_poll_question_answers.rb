class AddHiddenFieldToPollQuestionAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :poll_question_answers, :hidden, :boolean, default: false
  end
end
