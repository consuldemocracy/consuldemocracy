class CreateLegislationQuestions < ActiveRecord::Migration
  def change
    create_table :legislation_questions do |t|
      t.references :legislation_process, index: true
      t.text :title
      t.integer :answers_count, default: 0

      t.datetime :hidden_at, index: true

      t.timestamps null: false
    end

    create_table :legislation_question_options do |t|
      t.references :legislation_question, index: true
      t.string :value
      t.integer :answers_count, default: 0

      t.datetime :hidden_at, index: true

      t.timestamps null: false
    end
  end
end
