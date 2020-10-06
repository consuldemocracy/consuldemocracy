class RemoveDeprecatedFieldsFromDebates < ActiveRecord::Migration[5.1]
  def change
    remove_column :debates, :deprecated_title, :string
    remove_column :debates, :deprecated_description, :text
  end
end
