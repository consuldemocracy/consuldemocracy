class AddMainButtonToBudgets < ActiveRecord::Migration[5.0]
  def change
    add_column :budgets, :main_button_text, :string
    add_column :budgets, :main_button_url, :string
  end
end
