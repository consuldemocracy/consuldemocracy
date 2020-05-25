class AddMostVotedToPollQuestionAnswer < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_question_answers, :most_voted, :boolean, default: false
  end
end
