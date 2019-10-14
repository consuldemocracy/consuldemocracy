class ChangeBudgetDescription < ActiveRecord::Migration
  def change
    remove_column :budgets, :description, :text
    add_column :budgets, :description_accepting, :text
    add_column :budgets, :description_reviewing, :text
    add_column :budgets, :description_selecting, :text
    add_column :budgets, :description_valuating, :text
    add_column :budgets, :description_balloting, :text
    add_column :budgets, :description_reviewing_ballots, :text
    add_column :budgets, :description_finished, :text
  end
end
