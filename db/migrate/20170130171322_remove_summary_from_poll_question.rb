class RemoveSummaryFromPollQuestion < ActiveRecord::Migration[4.2]
  def change
    remove_column :poll_questions, :summary, :string
  end
end
