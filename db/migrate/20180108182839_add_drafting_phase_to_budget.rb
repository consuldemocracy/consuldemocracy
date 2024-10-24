class AddDraftingPhaseToBudget < ActiveRecord::Migration[4.2]
  def change
    add_column :budgets, :description_drafting, :text
  end
end
