class AddMainLinkToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :main_link_url, :string
    add_column :budget_translations, :main_link_text, :string
  end
end
