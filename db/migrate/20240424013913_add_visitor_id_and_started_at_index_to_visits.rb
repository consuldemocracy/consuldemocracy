class AddVisitorIdAndStartedAtIndexToVisits < ActiveRecord::Migration[7.0]
  def change
    add_index :visits, [:visitor_id, :started_at]
  end
end
