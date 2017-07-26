class CreateLocalCensusRecords < ActiveRecord::Migration
  def change
    create_table :local_census_records do |t|
      t.string :document_number, null: false
      t.string :document_type, null: false
      t.date :date_of_birth, null: false
      t.string :postal_code, null: false
      t.integer :user_id

      t.timestamps null: false
    end

    add_foreign_key :local_census_records, :users, column: :user_id
  end
end
