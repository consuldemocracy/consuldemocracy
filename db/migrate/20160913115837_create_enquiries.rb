class CreateEnquiries < ActiveRecord::Migration
  def change
    create_table :enquiries do |t|
      t.integer :author_id
      t.string :question
      t.string :title
      t.string :summary
      t.text :description
      t.string :external_url
      t.datetime :open_at
      t.datetime :closed_at

      t.timestamps null: false
    end

    add_index :enquiries, :author_id
    add_foreign_key :enquiries, :users, column: :author_id
  end
end
