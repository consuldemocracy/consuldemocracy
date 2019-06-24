class AddNameFieldToSignatureSheets < ActiveRecord::Migration[5.0]
  def change
    add_column :signature_sheets, :title, :string
  end
end
