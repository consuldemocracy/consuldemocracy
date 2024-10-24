class CreateSignatures < ActiveRecord::Migration[4.2]
  def change
    create_table :signatures do |t|
      t.references :signature_sheet
      t.references :user
      t.string :document_number
      t.boolean :verified, default: false
      t.timestamps
    end
  end
end
