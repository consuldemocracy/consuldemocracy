class AddDescriptionToValuators < ActiveRecord::Migration
  def change
    add_column :valuators, :description, :string
  end
end
