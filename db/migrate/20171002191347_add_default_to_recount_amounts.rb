class AddDefaultToRecountAmounts < ActiveRecord::Migration
  def change
    change_column_default :poll_recounts, :white_amount, 0
    change_column_default :poll_recounts, :null_amount, 0
    change_column_default :poll_recounts, :total_amount, 0
  end
end
