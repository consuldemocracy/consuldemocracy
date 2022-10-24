class TranslateBudgetMainLinkUrl < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_translations, :main_link_url, :string
    remove_column :budgets, :main_link_url, :string
  end
end
