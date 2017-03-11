class ReplaceGeozonesByHeadingsInBudgets < ActiveRecord::Migration
  def change
    remove_column :budget_investments, :geozone_id
    remove_column :budget_ballots, :geozone_id

    add_reference :budget_investments, :heading, index: true
    add_reference :budget_ballots, :heading, index: true
  end
end
