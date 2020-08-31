class RemoveDeprecatedFieldsFromProposals < ActiveRecord::Migration[5.1]
  def change
    remove_column :proposals, :deprecated_title, :string
    remove_column :proposals, :deprecated_description, :text
    remove_column :proposals, :deprecated_summary, :text
    remove_column :proposals, :deprecated_retired_explanation, :text
  end
end
