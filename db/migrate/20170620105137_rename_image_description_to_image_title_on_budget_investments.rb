class RenameImageDescriptionToImageTitleOnBudgetInvestments < ActiveRecord::Migration
  def change
    rename_column :budget_investments, :image_description, :image_title
  end
end
