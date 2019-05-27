class AddTsvToPollQuestions < ActiveRecord::Migration[4.2]
  def up
    add_column :poll_questions, :tsv, :tsvector
    add_index :poll_questions, :tsv, using: "gin"
  end

  def down
    remove_index :poll_questions, :tsv
    remove_column :poll_questions, :tsv
  end
end
