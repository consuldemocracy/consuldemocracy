class CreateBudgetHeadingVoters < ActiveRecord::Migration
  def change
    create_table :budget_heading_voters do |t|
      t.belongs_to :user, index: true
      t.belongs_to :budget_heading, index: true
      t.timestamps
    end
  end
end
