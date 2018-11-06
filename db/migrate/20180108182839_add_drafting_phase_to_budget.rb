class AddDraftingPhaseToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :description_drafting, :text
  end
end
