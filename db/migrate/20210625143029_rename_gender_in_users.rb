class RenameGenderInUsers < ActiveRecord::Migration[5.2]
  def change
	rename_column :users, :gender, :sexo
  end
end
