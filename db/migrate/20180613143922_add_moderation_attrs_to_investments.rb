class AddModerationAttrsToInvestments < ActiveRecord::Migration
  def change
    change_table :budget_investments do |t|
      t.datetime :confirmed_hide_at
      t.datetime :ignored_flag_at
      t.integer :flags_count, default: 0
    end
  end
end
