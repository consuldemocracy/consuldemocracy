class AddGeozoneToBudgetInvestment < ActiveRecord::Migration
  def up
    add_reference :budget_investments, :geozone, index: true
  end

  def down
    remove_reference :budget_investments, :geozone
  end
end
