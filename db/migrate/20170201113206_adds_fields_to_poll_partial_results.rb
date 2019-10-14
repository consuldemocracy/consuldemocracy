class AddsFieldsToPollPartialResults < ActiveRecord::Migration
  def change
    add_column :poll_partial_results, :date, :date
    add_column :poll_partial_results, :booth_assignment_id, :integer
    add_column :poll_partial_results, :officer_assignment_id, :integer

    add_index :poll_partial_results, [:booth_assignment_id, :date]
  end
end
