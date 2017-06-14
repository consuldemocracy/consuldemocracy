class AddImageDescriptionToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :image_description, :string
  end
end
