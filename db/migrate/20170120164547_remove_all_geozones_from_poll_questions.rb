class RemoveAllGeozonesFromPollQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :poll_questions, :all_geozones, :boolean
  end
end
