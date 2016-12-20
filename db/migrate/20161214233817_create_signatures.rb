class CreateSignatures < ActiveRecord::Migration
  def change
    create_table :signatures do |t|
      t.references :signature_sheet
      t.references :user
      t.string :document_number
      t.string :status, default: nil
      t.timestamps
    end
  end
end
