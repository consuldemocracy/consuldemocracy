class AddMainLinkToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :main_link_text, :string
    add_column :budgets, :main_link_url, :string
  end
end
