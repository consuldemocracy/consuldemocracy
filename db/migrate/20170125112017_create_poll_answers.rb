class CreatePollAnswers < ActiveRecord::Migration[4.2]
  def change
    create_table :poll_answers do |t|
      t.integer :question_id
      t.integer :author_id
      t.string :answer

      t.timestamps
    end

    add_index :poll_answers, :question_id
    add_index :poll_answers, :author_id
    add_index :poll_answers, [:question_id, :answer]
  end
end
