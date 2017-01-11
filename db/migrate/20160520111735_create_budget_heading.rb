class CreateBudgetHeading < ActiveRecord::Migration
  def change
    create_table :budget_headings do |t|
      t.references :group, index: true
      t.references :geozone
      t.string :name, limit: 50
      t.integer :price, limit: 8
    end
  end
end
