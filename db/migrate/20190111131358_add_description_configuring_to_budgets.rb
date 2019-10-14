class AddDescriptionConfiguringToBudgets < ActiveRecord::Migration
  def change
    add_column :budgets, :description_configuring, :text
  end
end
