class CreateFailedCensusCalls < ActiveRecord::Migration[4.2]
  def change
    create_table :failed_census_calls do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :document_number
      t.string :document_type
      t.date :date_of_birth
      t.string :postal_code

      t.timestamps null: false
    end
  end
end
