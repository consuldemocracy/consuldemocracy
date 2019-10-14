class CreatePollQuestions < ActiveRecord::Migration
  def change
    create_table :poll_questions do |t|
      t.references :proposal, index: true, foreign_key: true
      t.references :poll, index: true, foreign_key: true
      t.references :author, index: true # foreign key added later due to rails 4
      t.string :author_visible_name
      t.string :title
      t.string :question
      t.string :summary
      t.string :valid_answers
      t.text :description
      t.integer :comments_count
      t.datetime :hidden_at

      t.timestamps
    end

    add_foreign_key :poll_questions, :users, column: :author_id
  end
end
