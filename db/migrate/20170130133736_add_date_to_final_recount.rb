class AddDateToFinalRecount < ActiveRecord::Migration
  def change
    add_column :poll_final_recounts, :date, :datetime, null: false
  end
end
