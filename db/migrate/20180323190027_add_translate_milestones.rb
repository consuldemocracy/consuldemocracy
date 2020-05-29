class AddTranslateMilestones < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_investment_milestone_translations do |t|
      t.integer    :budget_investment_milestone_id, null: false
      t.string     :locale,                         null: false
      t.timestamps                                  null: false
      t.string     :title
      t.text       :description
    end

    add_index :budget_investment_milestone_translations,
              :budget_investment_milestone_id,
              name: "index_6770e7675fe296cf87aa0fd90492c141b5269e0b"

    add_index :budget_investment_milestone_translations,
              :locale,
              name: "index_budget_investment_milestone_translations_on_locale"
  end
end
