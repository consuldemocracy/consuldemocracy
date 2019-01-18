class AddMaxVotableHeadingsToBudgetGroups < ActiveRecord::Migration
  def change
    add_column :budget_groups, :max_votable_headings, :integer, default: 1
  end
end
