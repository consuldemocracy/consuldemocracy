class RenameDeprecatedTranslatablePollFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :polls, :name, :deprecated_name
    rename_column :polls, :summary, :deprecated_summary
    rename_column :polls, :description, :deprecated_description
  end
end
