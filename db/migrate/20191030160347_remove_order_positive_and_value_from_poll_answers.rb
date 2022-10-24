class RemoveOrderPositiveAndValueFromPollAnswers < ActiveRecord::Migration[5.0]
  def change
    remove_column :poll_answers, :value, :integer
    remove_column :poll_answers, :positive, :boolean
    remove_column :poll_answers, :order, :integer

    remove_column :poll_question_answers, :hidden, :boolean, default: false
  end
end
