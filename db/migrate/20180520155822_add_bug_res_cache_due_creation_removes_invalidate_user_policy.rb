class AddBugResCacheDueCreationRemovesInvalidateUserPolicy < ActiveRecord::Migration
  def change
  	add_column :budgets, :not_sent_participant_count, :integer, default: 0
  end
end
