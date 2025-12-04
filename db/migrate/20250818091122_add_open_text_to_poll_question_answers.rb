class AddOpenTextToPollQuestionAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :poll_question_answers, :open_text, :boolean, default: false
  end
end
