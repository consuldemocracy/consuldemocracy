class CreateBannerSections < ActiveRecord::Migration[4.2]
  def change
    create_table :banner_sections do |t|
      t.integer :banner_id
      t.integer :web_section_id
      t.timestamps null: false
    end
  end
end
