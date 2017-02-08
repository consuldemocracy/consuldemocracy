class ChangeDatetimesToDateInRecountsAndAssignments < ActiveRecord::Migration
  def up
    change_column :poll_recounts, :date, :date, null: false
    change_column :poll_final_recounts, :date, :date, null: false
    change_column :poll_officer_assignments, :date, :date, null: false
  end

  def down
    change_column :poll_recounts, :date, :datetime, null: false
    change_column :poll_final_recounts, :date, :datetime, null: false
    change_column :poll_officer_assignments, :date, :datetime, null: false
  end
end
