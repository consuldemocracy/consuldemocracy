class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|

      t.references :attachable, polymorphic: true, null: false
      t.string :file, null: false
      t.string :title
      t.timestamps null: false
    end
  end
end
