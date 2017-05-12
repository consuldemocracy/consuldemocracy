class AddPhaseToBudgetRecommendations < ActiveRecord::Migration
  def change
    add_column :budget_recommendations, :phase, :string, default: 'selecting'
  end
end
