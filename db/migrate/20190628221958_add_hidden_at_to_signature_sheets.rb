class AddHiddenAtToSignatureSheets < ActiveRecord::Migration[5.0]
  def change
    add_column :signature_sheets, :hidden_at, :datetime
    add_index :signature_sheets, :hidden_at
  end
end
