class AddTraceabilityFieldsToNvotes < ActiveRecord::Migration
  def change
    add_column :poll_nvotes, :officer_assignment_id, :integer
    add_column :poll_nvotes, :booth_assignment_id, :integer
    add_foreign_key :poll_nvotes, :poll_officer_assignments, column: :officer_assignment_id
    add_foreign_key :poll_nvotes, :poll_booth_assignments, column: :booth_assignment_id
  end
end
