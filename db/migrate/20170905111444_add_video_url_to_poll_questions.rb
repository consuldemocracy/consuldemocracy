class AddVideoUrlToPollQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_questions, :video_url, :string
  end
end
