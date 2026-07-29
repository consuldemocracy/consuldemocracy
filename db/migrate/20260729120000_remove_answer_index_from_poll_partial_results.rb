class RemoveAnswerIndexFromPollPartialResults < ActiveRecord::Migration[7.2]
  def change
    remove_index :poll_partial_results,
                 column: :answer,
                 name: "index_poll_partial_results_on_answer"
  end
end
