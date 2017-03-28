class CreatePollPartialResult < ActiveRecord::Migration
  def change
    create_table :poll_partial_results do |t|
      t.integer :question_id, index: true
      t.integer :author_id, index: true
      t.string :answer, index: true
      t.integer :amount
      t.string :origin, index: true
    end

    add_foreign_key(:poll_partial_results, :users, column: :author_id)
    add_foreign_key(:poll_partial_results, :poll_questions, column: :question_id)
  end
end
