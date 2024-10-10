class RemoveAnswerIdFromPollVoters < ActiveRecord::Migration[7.0]
  def change
    remove_column :poll_voters, :answer_id, :integer
  end
end
