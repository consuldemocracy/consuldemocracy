class AddPublishedStatusToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :published, :boolean
  end
end
