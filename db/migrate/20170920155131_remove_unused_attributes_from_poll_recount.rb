class RemoveUnusedAttributesFromPollRecount < ActiveRecord::Migration
  def change
    change_table :poll_recounts do |t|
      t.remove :amount, :amount_log
    end
  end
end
