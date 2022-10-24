class CreateNewsletters < ActiveRecord::Migration[4.2]
  def change
    create_table :newsletters do |t|
      t.string :subject
      t.integer :segment_recipient
      t.string :from
      t.text :body
      t.date :sent_at, default: nil

      t.timestamps null: false
    end
  end
end
