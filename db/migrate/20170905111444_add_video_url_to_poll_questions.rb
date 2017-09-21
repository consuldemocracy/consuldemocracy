class AddVideoUrlToPollQuestions < ActiveRecord::Migration
  def change
    add_column :poll_questions, :video_url, :string
  end
end
