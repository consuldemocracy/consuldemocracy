class AddPositionToCategoriesAndSubcategories < ActiveRecord::Migration
  def change
    add_column :categories, :position, :integer
    add_column :subcategories, :position, :integer
  end
end
