class AddMoreIndexesForAhoy < ActiveRecord::Migration[4.2]
  def change
    add_index :ahoy_events, [:name, :time]
    add_index :visits, [:started_at]
  end
end
