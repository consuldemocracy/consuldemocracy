class AddDateOfBirthToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :date_of_birth, :date
  end
end
