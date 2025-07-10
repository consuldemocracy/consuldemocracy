class AddPostalCodeToSignatures < ActiveRecord::Migration[4.2]
  def change
    add_column :signatures, :postal_code, :string
  end
end
