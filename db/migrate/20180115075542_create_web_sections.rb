class CreateWebSections < ActiveRecord::Migration
  def change
    create_table :web_sections do |t|
      t.text :name
      t.timestamps null: false
    end
  end
end
