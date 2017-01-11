class AddSlugToBudgets < ActiveRecord::Migration
  def change
    add_column :budgets, :slug, :string
  end
end
