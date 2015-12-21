class AddCategoriesToProposals < ActiveRecord::Migration
  def change
    change_table :proposals do |t|
      t.references :category
      t.references :subcategory
    end
  end
end
