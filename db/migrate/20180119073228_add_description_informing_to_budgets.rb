class AddDescriptionInformingToBudgets < ActiveRecord::Migration
  def change
    add_column :budgets, :description_informing, :text
  end
end
