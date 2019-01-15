class RemoveTranslatedAttributesFromLegislationProcesses < ActiveRecord::Migration
  def change
    remove_columns :legislation_processes, :title, :summary, :description,
      :additional_info
  end
end
