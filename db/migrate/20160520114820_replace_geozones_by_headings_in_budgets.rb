class ReplaceGeozonesByHeadingsInBudgets < ActiveRecord::Migration[4.2]
  def change
    remove_column :budget_investments, :geozone_id, :integer
    remove_column :budget_ballots, :geozone_id, :integer

    add_reference :budget_investments, :heading, index: true
    add_reference :budget_ballots, :heading, index: true
  end
end
