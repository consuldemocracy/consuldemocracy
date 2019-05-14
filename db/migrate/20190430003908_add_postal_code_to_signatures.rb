class AddPostalCodeToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :postal_code, :string
  end
end
