class RemoveAllGeozonesFromPollQuestions < ActiveRecord::Migration
  def change
    remove_column :poll_questions, :all_geozones, :boolean
  end
end
