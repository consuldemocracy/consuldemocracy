class AddHideMoneyToBudgets < ActiveRecord::Migration[5.1]
  def change
    add_column :budgets, :hide_money, :boolean, default: false
  end
end
