class RemoveDeprecatedTranslatableFieldsFromLegislationProcesses < ActiveRecord::Migration[4.2]
  def change
    remove_column :legislation_processes, :title, :string
    remove_column :legislation_processes, :summary, :text
    remove_column :legislation_processes, :description, :text
    remove_column :legislation_processes, :additional_info, :text
  end
end
