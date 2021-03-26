class CreatePageParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :page_participants do |t|
      t.references :site_customization_pages, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
