class AddTranslateMilestones < ActiveRecord::Migration
  def change
    create_table :budget_investment_milestone_translations do |t|
      t.integer :budget_investment_milestone_id, null: false
      t.string  :locale,                         null: false
      t.string  :title
      t.text    :description

      t.timestamps null: false
    end
  end
end
