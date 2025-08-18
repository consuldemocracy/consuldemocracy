class AddAllowsCustomTextToPollQuestionAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :poll_question_answers, :allows_custom_text, :boolean, default: false
  end
end
