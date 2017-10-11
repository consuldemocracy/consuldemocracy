class AddGivenOrderToPollQuestionAnswers < ActiveRecord::Migration
  def change
    add_column :poll_question_answers, :given_order, :integer, default: 1
  end
end
