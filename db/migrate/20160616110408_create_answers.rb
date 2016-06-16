class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :author_id
      t.text :text
      t.string :context
      t.timestamps null: false
    end

    add_index :answers, :author_id
    add_index :answers, :context
  end
end
