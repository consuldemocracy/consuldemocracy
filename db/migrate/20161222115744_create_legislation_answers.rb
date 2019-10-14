class CreateLegislationAnswers < ActiveRecord::Migration
  def change
    create_table :legislation_answers do |t|
      t.references :legislation_question, index: true
      t.references :legislation_question_option, index: true
      t.references :user, index: true

      t.datetime :hidden_at, index: true

      t.timestamps null: false
    end
  end
end
