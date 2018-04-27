class AddSelectedByAssembly < ActiveRecord::Migration
  def change
    add_column :budget_investments, :selected_by_assembly, :boolean, default: false, null: false
  end
end
