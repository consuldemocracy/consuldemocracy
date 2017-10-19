class AddMostVotedToPollQuestionAnswer < ActiveRecord::Migration
  def change
    add_column :poll_question_answers, :most_voted, :boolean
  end
end
