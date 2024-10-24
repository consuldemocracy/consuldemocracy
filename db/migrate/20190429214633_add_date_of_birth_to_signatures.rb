class AddDateOfBirthToSignatures < ActiveRecord::Migration[4.2]
  def change
    add_column :signatures, :date_of_birth, :date
  end
end
