class AddDescriptionInformingToBudgets < ActiveRecord::Migration[4.2]
  def change
    add_column :budgets, :description_informing, :text
  end
end
