class CreateAnnotations < ActiveRecord::Migration[4.2]
  def change
    create_table :annotations do |t|
      t.string :quote
      t.text :ranges
      t.text :text

      t.timestamps null: false
    end
  end
end
