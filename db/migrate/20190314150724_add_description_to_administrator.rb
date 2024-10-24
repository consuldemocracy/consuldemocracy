class AddDescriptionToAdministrator < ActiveRecord::Migration[4.2]
  def change
    add_column :administrators, :description, :string
  end
end
