class CreateSubcategories < ActiveRecord::Migration
  def change
    create_table :subcategories do |t|
      t.text :name
      t.text :description

      t.references :category

      t.timestamps null: false
    end
  end
end
