class CreateSurveyAnswers < ActiveRecord::Migration
  def change
    create_table :survey_answers do |t|
      t.string :survey_code
      t.json :answers
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
