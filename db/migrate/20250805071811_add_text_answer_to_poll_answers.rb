class AddTextAnswerToPollAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :poll_answers, :text_answer, :string
  end
end
