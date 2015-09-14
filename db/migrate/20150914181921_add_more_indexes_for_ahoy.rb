class AddMoreIndexesForAhoy < ActiveRecord::Migration
  def change
    add_index :ahoy_events, [:name, :time]
    add_index :visits, [:started_at]
  end
end

