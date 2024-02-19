class AddMainLinkToBudgetsWhenUpgrading < ActiveRecord::Migration[5.2]
  def up
    unless column_exists? :budgets, :main_link_url
      add_column :budgets, :main_link_url, :string
    end

    unless column_exists? :budget_translations, :main_link_text
      add_column :budget_translations, :main_link_text, :string
    end
  end
end
