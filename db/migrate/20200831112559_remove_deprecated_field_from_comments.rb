class RemoveDeprecatedFieldFromComments < ActiveRecord::Migration[5.1]
  def change
    remove_column :comments, :deprecated_body, :text
  end
end
