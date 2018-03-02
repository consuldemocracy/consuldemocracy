class RemoveUnusedSurveyTables < ActiveRecord::Migration
  def change
    drop_table :survey_answers
    drop_table :open_answers
  end
end
