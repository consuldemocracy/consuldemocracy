class RemoveSummaryFromPollQuestion < ActiveRecord::Migration
  def change
    remove_column :poll_questions, :summary
  end
end
