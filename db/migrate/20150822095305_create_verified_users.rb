class CreateVerifiedUsers < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.data_source_exists?("verified_users")
      create_table :verified_users do |t|
        t.string :document_number
        t.string :document_type
        t.string :phone
        t.string :email

        t.timestamps null: false
      end
    end
  end
end
