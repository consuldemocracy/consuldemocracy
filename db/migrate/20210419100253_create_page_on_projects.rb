class CreatePageOnProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :page_on_projects do |t|
      t.references :project, foreign_key: true
      t.references :site_customization_page, foreign_key: true

      t.timestamps
    end
  end
end
