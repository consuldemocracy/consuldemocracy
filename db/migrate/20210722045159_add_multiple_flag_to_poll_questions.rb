class AddMultipleFlagToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_questions, :multiple, :boolean, default: false
  end
end
