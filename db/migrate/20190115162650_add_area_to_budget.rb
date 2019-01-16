class AddAreaToBudget < ActiveRecord::Migration
  def up
    add_column :budgets, :areas, :boolean, default: false
  end

  def down
    remove_column :budgets, :areas
  end
end
