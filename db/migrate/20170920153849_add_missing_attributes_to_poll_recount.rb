class AddMissingAttributesToPollRecount < ActiveRecord::Migration
  def change
    change_table :poll_recounts do |t|
      t.integer :null_amount
      t.integer :total_amount
      t.integer :white_amount
      t.text    :null_amount_log,  default: ""
      t.text    :total_amount_log, default: ""
      t.text    :white_amount_log, default: ""
    end
  end
end
