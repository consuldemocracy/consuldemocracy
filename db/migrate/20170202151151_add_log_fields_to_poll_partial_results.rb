class AddLogFieldsToPollPartialResults < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_partial_results, :amount_log, :text, default: ""
    add_column :poll_partial_results, :officer_assignment_id_log, :text, default: ""
    add_column :poll_partial_results, :author_id_log, :text, default: ""
  end
end
