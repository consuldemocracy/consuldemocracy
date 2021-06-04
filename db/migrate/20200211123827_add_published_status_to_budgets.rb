class AddPublishedStatusToBudgets < ActiveRecord::Migration[5.0]
  def change
    add_column :budgets, :published, :boolean
  end
end
