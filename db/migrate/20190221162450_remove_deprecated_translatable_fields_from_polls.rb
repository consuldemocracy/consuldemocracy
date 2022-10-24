class RemoveDeprecatedTranslatableFieldsFromPolls < ActiveRecord::Migration[4.2]
  def change
    remove_column :polls, :name, :string
    remove_column :polls, :summary, :text
    remove_column :polls, :description, :text
  end
end
