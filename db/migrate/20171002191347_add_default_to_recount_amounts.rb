class AddDefaultToRecountAmounts < ActiveRecord::Migration[4.2]
  def change
    change_column_default :poll_recounts, :white_amount, from: nil, to: 0
    change_column_default :poll_recounts, :null_amount, from: nil, to: 0
    change_column_default :poll_recounts, :total_amount, from: nil, to: 0
  end
end
