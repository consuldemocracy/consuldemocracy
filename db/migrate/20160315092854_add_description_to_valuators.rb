class AddDescriptionToValuators < ActiveRecord::Migration[4.2]
  def change
    add_column :valuators, :description, :string
  end
end
