class AddCategoryIdAndSubcategoryIdToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :category_id, :integer
    add_column :meetings, :subcategory_id, :integer
  end
end
