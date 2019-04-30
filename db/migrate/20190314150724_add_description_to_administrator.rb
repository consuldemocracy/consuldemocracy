class AddDescriptionToAdministrator < ActiveRecord::Migration
  def change
    add_column :administrators, :description, :string
  end
end
