class AddOpenTextToPollQuestionAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :poll_question_answers, :open_text, :boolean, default: false
    add_column :poll_answers, :text_answer, :string
    add_column :polls, :preliminary_results, :boolean, default: false
  end
end
