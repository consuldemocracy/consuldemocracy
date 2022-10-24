class CreateTrackers < ActiveRecord::Migration[5.0]
  def change
    create_table :trackers do |t|
      t.references :user, foreign_key: true
      t.string :description
      t.integer :budget_investment_count, default: 0

      t.timestamps
    end
  end
end
