class AddAllGeozonesToPollQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_questions, :all_geozones, :boolean, default: false
  end
end
