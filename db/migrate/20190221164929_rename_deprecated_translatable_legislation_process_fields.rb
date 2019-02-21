class RenameDeprecatedTranslatableLegislationProcessFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :legislation_processes, :title, :deprecated_title
    rename_column :legislation_processes, :summary, :deprecated_summary
    rename_column :legislation_processes, :description, :deprecated_description
    rename_column :legislation_processes, :additional_info, :deprecated_additional_info
  end
end
