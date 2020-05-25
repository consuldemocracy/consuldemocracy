class AddBudgetInvestmentsCountToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, "budget/investments_count", :integer, default: 0
  end
end
