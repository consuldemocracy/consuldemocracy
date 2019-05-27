class AddDateToFinalRecount < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_final_recounts, :date, :datetime, null: false
  end
end
