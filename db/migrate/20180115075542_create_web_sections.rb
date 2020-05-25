class CreateWebSections < ActiveRecord::Migration[4.2]
  def change
    create_table :web_sections do |t|
      t.text :name
      t.timestamps null: false
    end
  end
end
