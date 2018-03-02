class CreateBudgetRecommendations < ActiveRecord::Migration
  def change
    create_table :budget_recommendations do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :investment_id
      t.integer :budget_id
      t.timestamps
    end
  end
end
