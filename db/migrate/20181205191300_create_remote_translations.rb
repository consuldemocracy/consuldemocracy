class CreateRemoteTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :remote_translations do |t|
      t.string :locale
      t.integer :remote_translatable_id
      t.string  :remote_translatable_type
      t.text :error_message

      t.timestamps null: false
    end
  end
end
