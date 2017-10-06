class CreatePollQuestionAnswerVideos < ActiveRecord::Migration
  def change
    create_table :poll_question_answer_videos do |t|
      t.string :title
      t.string :url
      t.integer :answer_id, index: true
    end

    add_foreign_key :poll_question_answer_videos, :poll_question_answers, column: :answer_id
  end
end
