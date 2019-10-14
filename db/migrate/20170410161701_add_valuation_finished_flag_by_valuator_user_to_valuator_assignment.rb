class AddValuationFinishedFlagByValuatorUserToValuatorAssignment < ActiveRecord::Migration
  def change
    add_column :budget_valuator_assignments, :finished_by_user_at, :datetime, default: nil
  end
end
