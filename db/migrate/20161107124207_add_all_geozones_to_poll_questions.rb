class AddAllGeozonesToPollQuestions < ActiveRecord::Migration
  def change
    add_column :poll_questions, :all_geozones, :boolean, default: false
  end
end
