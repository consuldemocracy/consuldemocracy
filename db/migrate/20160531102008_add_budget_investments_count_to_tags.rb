class AddBudgetInvestmentsCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, "budget/investments_count", :integer, default: 0
  end
end
