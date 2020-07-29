class AddPollTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :poll_translations do |t|
      t.integer :poll_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :name
      t.text :summary
      t.text :description

      t.index :locale
      t.index :poll_id
    end
  end
end
