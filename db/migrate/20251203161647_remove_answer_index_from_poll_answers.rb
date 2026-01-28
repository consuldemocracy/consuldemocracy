class RemoveAnswerIndexFromPollAnswers < ActiveRecord::Migration[7.2]
  def change
    remove_index :poll_answers,
                 column: [:question_id, :answer],
                 name: "index_poll_answers_on_question_id_and_answer"
  end
end
